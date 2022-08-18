--[[
/* Copyright (C) 2022 SAS Institute Inc. Cary, NC, USA */

/*!
\file

\brief   Module provides JSON parsing functionality for interacting with the SAS Risk Cirrus Core Objects REST API

\details
   The following functions are available:
   - parseJSONFile Parse a simple (one level) JSON structure
   - ...

\section ..

   Returns the list of workgroups defined in SAS Model Implementation Platform <br>

   <b>Syntax:</b> <i>(\<filename�fileref\>, output)</i>

   <b>Sample JSON input structure: </b>
   \code

   \endcode

   <b>Sample Output: </b>


\ingroup commonAnalytics

\author  SAS Institute Inc.

\date    2022

*/

]]


local filesys = require 'sas.risk.utils.filesys'
local stringutils = require 'sas.risk.utils.stringutils'
local args = require 'sas.risk.utils.args'
local errors = require 'sas.risk.utils.errors'
local sas_msg = require 'sas.risk.utils.sas_msg'
local tableutils = require 'sas.risk.utils.tableutils'
local json = require 'sas.risk.utils.json'
local json_utils = require 'sas.risk.irm.irm_rest_parser'

json.strictTypes = true

local M = {}

-- Return configuration set schema info
coreConfigSetAttr = function()
   -- Declare table structure
    local result = {
       vars = {
          -- Standard fields
          key = {type = "C"}
          , objectId = {type = "C"}
          , sourceSystemCd = {type = "C"}
          , name = {type = "C"}
          , description = {type = "C"}
          , versionNm = {type = "C"}
          , statusCd = {type = "C"}
          , type = {type = "C"}
          , createdInTag = {type = "C"}
          , sharedWithTags = {type = "C"}
       }
    }
    -- Return table structure
    return result
 end

-- Return configuration table schema info
coreConfigTableAttr = function()
  -- Declare table structure
   local result = {
      vars = {
         -- Standard fields
         key = {type = "C"}
         , objectId = {type = "C"}
         , sourceSystemCd = {type = "C"}
         , name = {type = "C"}
         , description = {type = "C"}
         , versionNm = {type = "C"}
         , statusCd = {type = "C"}
         , type = {type = "C"}
         , createdInTag = {type = "C"}
         , sharedWithTags = {type = "C"}
      }
   }
   -- Return table structure
   return result
end


-- Process Core item attributes
coreProcessAttr = function(item, func)

   -- Initialize output row
   local row = {}

   for attrName, attrValue in pairs(item) do
      -- Process customFields (if available)
      if(attrName == "customFields") then
         -- Loop through all customFields
         for key, value in pairs(attrValue) do
            if(type(value) == "table") then
               -- Convert table into plain string
               row[key] = json:encode(value)
            else
               row[key] = value
            end
         end
      else -- Process all other attributes
         if(type(attrValue) == "table") then
            -- Convert table into plain string
            row[attrName] = json:encode(attrValue)
         else
            row[attrName] = attrValue
         end

         -- Parse Dimensional Points (grab only the first)
         if(attrName == "dimensionalPoints" and #attrValue > 0) then
            row.dimensionalPoint = attrValue[1]
         end

      end

   end

   -- Use custom function if provided
   if(func ~= nil) then
      row = func(item, row)
   end

   -- Return the processed row
   return row
end


-- General wrapper for REST calls of type objects/<solution>/<CustomObject>
coreProcessItems = function(schema, jsonTable, output, func)
   -- Declare output table structure (copy from the input schema)
   local result = schema
      
   if jsonTable ~= nil then
      -- Check for errors
      if jsonTable.errorCode ~= nil then
         result = {}
         local row = {}
         -- Grab Error details
         row.errorCode = jsonTable.errorCode
         row.message = jsonTable.message
         row.remediation = jsonTable.remediation
         row.httpStatusCode = jsonTable.httpStatusCode
         table.insert(result, row)
         -- Print error info to the log
         sas.print("%1z" .. row.message .. ". " .. row.remediation)
      else
         -- Check if this is a collection of items
         if jsonTable.items ~= nil then
            -- Loop through the items
            for i, row in pairs(jsonTable.items) do
               row.itemsCount = jsonTable.count
               -- Process current row
               local processedRecord = coreProcessAttr(row, func)
               -- Check if the above call returned a single record or multiple records
               if #processedRecord > 0 then
                  -- It's a table with multiple records: Loop through all records
                  for j = 1, #processedRecord do
                     -- Insert current record to the result
                     table.insert(result, processedRecord[j])
                  end
               else
                  -- It's a single record: add it to the output table
                  table.insert(result, processedRecord)
               end
            end
            -- Process boolean attributes
            result = json_utils.processBoolean(result)
         else
            -- Check if this is a single item
            if jsonTable.key ~= nil then

               -- Process current row
               local processedRecord = coreProcessAttr(jsonTable, func)
               -- Check if the above call returned a single record or multiple records
               if #processedRecord > 0 then
                  -- It's a table with multiple records: Loop through all records
                  for j = 1, #processedRecord do
                     processedRecord[j].itemsCount = 1
                     -- Insert current record to the result
                     table.insert(result, processedRecord[j])
                  end
               else
                  processedRecord.itemsCount = 1
                  -- It's a single record: add it to the output table
                  table.insert(result, processedRecord)
               end

               -- Process boolean attributes
               result = json_utils.processBoolean(result)
            end
         end
      end

      if output ~= nil then
         if #result == 0 then
            -- Make sure there is at least one record
            result[1] = {key = -1}
            -- Write table
            sas.write_ds(result, output)
            -- Now remove the empty record
            sas.submit([[data @output@ ; set @output@ (obs = 0); run;]])
         else
            -- Write result
            sas.write_ds(result, output)
         end
      end
   end

   return result

end

-- Parser for riskCirrusObjects/objects/configurationTables/<configTableKey>

coreRestConfigTable = function(filename, output, output_data)
   -- Parse JSON
   local jsonTable = json_utils.parseJSONFile(filename)

   -- Define ConfigTable Attributes
   local schema = coreConfigTableAttr()

   -- Process all items - configset table info
   local result = coreProcessItems(schema, jsonTable, output)

   -- Lua table with the configTable data --
   local confResult = {}

   -- Loop through the Lua table with all the items --
   for key, value in pairs(result) do
      for result_key, result_value in pairs(value) do
         -- The configSet data is stored in the typeData property as a JSON string --
         if result_key == "typeData" and type(result_value) == "string" then
            -- Transform the JSON string in Lua table --
            local tdResult = json:decode(result_value)
            -- Loop through the typeData information --
            for td_key, td_value in pairs(tdResult) do
               -- The metadata of the columns is stored in the property vars property --
               if td_key == "vars" then
                   -- Lua table to store the vars --
                   local vars = {}
                   -- Loop through each variable --
                   for var_key, var_value in pairs(tdResult.vars) do
                     -- Each var will have an array of JSON objects (metadata info) --
                      -- First loop through the array which should have only one JSON object --
                      for meta_k, meta_v in pairs(var_value) do
                         -- Lua table to store the metadata --
                         local meta = {}
                         -- Second loop through the metadata info --					
                         for meta_key, meta_value in pairs(meta_v) do
                           -- Store the metadata in the lua meta table -- 
                           meta[meta_key] = meta_value
                        end
                        -- Store the variable and its metadata in the vars table -- 
                         vars[var_key] = meta
                      end
                   end
                   -- Store the vars table in the final table --
                   confResult["vars"] = vars
                   -- print("Vars info: " .. table.tostring(confResult))
               end
               -- The data will be stored in the data property of the typeData -- 
               if td_key == "data" then
                  -- The data value is a JSON Array (rows) of JSON objects (data) --
                  -- First loop through the array (rows) --
                  for row_k, row_v in pairs(tdResult.data) do
                     -- Lua table to store the row data --
                     local row = {}
                     -- Second loop through the JSON object (data) --
                     for row_key, row_value in pairs(row_v) do
                        -- Store each variable data in the row table --
                        row[row_key] = row_value
                     end
                     -- Insert the row with data in the final table --
                     table.insert(confResult,row)
                  end
               end
               -- print("Output info: " .. table.tostring(confResult))
               sas.write_ds(confResult, output_data)
            end
         end
        end
   end
end

M.coreRestConfigTable = coreRestConfigTable


-----------------------------
-- ConfigSets
-----------------------------

-- Parser for riskCirrusObjects/objects/configurationSets/<configSetKey>
coreRestConfigSet = function(filename, output)
   -- Parse JSON
   local jsonTable = json_utils.parseJSONFile(filename)
   -- Define ConfigSet Attributes
   local schema = coreConfigSetAttr()
   -- Process all items
   coreProcessItems(schema, jsonTable, output)
end

M.coreRestConfigSet = coreRestConfigSet


-- Parser for riskCirrusObjects/objects/<contentId>/dataDefinitions
coreRestDataDefinition = function(filename, outputSummary, outputColInfo, outputAggregationConfig)
   -- Parse JSON
   local jsonTable = json_utils.parseJSONFile(filename)
   -- Define dataDefinition Attributes
   local schema = coreSchemaDataDefinition()
   -- Process all items
   local result = coreProcessItems(schema, jsonTable, outputSummary)

   -- Process columnInfo field
   if outputColInfo ~= nil then
      local columnInfoTable = {vars = {}}
      columnInfoTable.vars.dataDefKey = result.vars.key
      columnInfoTable.vars.dataDefName = result.vars.name
      columnInfoTable.vars.key = {type = "C"}
      columnInfoTable.vars.name = {type = "C"}
      columnInfoTable.vars.config_readOnly = {type = "C"}
      columnInfoTable.vars.label = {type = "C"}
      columnInfoTable.vars.type = {type = "C"}
      columnInfoTable.vars.size = {type = "N"}
      columnInfoTable.vars.format = {type = "C"}
      columnInfoTable.vars.informat = {type = "C"}
      columnInfoTable.vars.primary_key_flg = {type = "C"}
      columnInfoTable.vars.partition_flg = {type = "C"}
      columnInfoTable.vars.filterable = {type = "C"}
      columnInfoTable.vars.classification = {type = "C"}
      columnInfoTable.vars.attributable = {type = "C"}
      columnInfoTable.vars.mandatory_segmentation = {type = "C"}
      columnInfoTable.vars.projection = {type = "C"}
      columnInfoTable.vars.fx_var = {type = "C"}
      -- Loop through all data definitions
      for i, row in ipairs(result) do
         if(row.columnInfo ~= nil) then
            -- row.columnInfo is a JSON table stored as a string: need to decode it
            local cols = json:decode(row.columnInfo)
         -- print(table.tostring(cols))
            -- Loop through all columnInfo
            for j, item in ipairs(cols) do
               local col = {}
               col.dataDefKey = row.key
               col.dataDefName = row.name
               -- Loop through all attributes of the column
               for attrName, attrValue in pairs(item) do
                  if type(attrValue) == "table" then
                     -- It is a complex parameter. Need to encode it
                     col[attrName] = json:encode(attrValue)
                  else
                     col[attrName] = attrValue
                  end
               end
               table.insert(columnInfoTable, col)
            end
         end
      end
      if #columnInfoTable == 0 then
         -- Make sure there is at least one record
         columnInfoTable[1] = {dataDefKey = -1}
         -- Write table
         sas.write_ds(columnInfoTable, outputColInfo)
         -- Now remove the empty record
         sas.submit([[data @outputColInfo@; set @outputColInfo@(obs = 0); run;]])
      else
         -- Write table
         sas.write_ds(columnInfoTable, outputColInfo)
      end
   end -- if outputColInfo ~= nil

   -- Process martAggregationConfig field
   if outputAggregationConfig ~= nil then
      local aggregationConfigTable = {vars = {}}
      aggregationConfigTable.vars.dataDefKey = result.vars.key
      aggregationConfigTable.vars.dataDefName = result.vars.name
      aggregationConfigTable.vars.var_name = {type = "C"}
      aggregationConfigTable.vars.var_scope = {type = "C"}
      aggregationConfigTable.vars.weight_var = {type = "C"}
      aggregationConfigTable.vars.alias = {type = "C"}

      -- Loop through all data definitions
      for i, row in ipairs(result) do
         if(row.martAggregationConfig ~= nil) then
            -- row.martAggregationConfig is a JSON table stored as a string: need to decode it
            local cols = json:decode(row.martAggregationConfig)
            -- Loop through all columnInfo
            for j, item in ipairs(cols.items) do
               local col = {}
               col.dataDefKey = row.key
               col.dataDefName = row.name
               -- Loop through all attributes of the column
               for attrName, attrValue in pairs(item) do
                  if type(attrValue) == "table" then
                     -- It is a complex parameter. Need to encode it
                     col[attrName] = json:encode(attrValue)
                  else
                     col[attrName] = attrValue
                  end
               end
               table.insert(aggregationConfigTable, col)
            end
         end
      end
      if #aggregationConfigTable == 0 then
         -- Make sure there is at least one record
         aggregationConfigTable[1] = {dataDefKey = -1}
         -- Write table
         sas.write_ds(aggregationConfigTable, outputAggregationConfig)
         -- Now remove the empty record
         sas.submit([[data @outputAggregationConfig@; set @outputAggregationConfig@(obs = 0); run;]])
      else
         -- Write table
         sas.write_ds(aggregationConfigTable, outputAggregationConfig)
      end
   end -- if outputAggregationConfig ~= nil

end
M.coreRestDataDefinition = coreRestDataDefinition


-- Attributes of the Core dataDefinition custom object
coreSchemaDataDefinition = function()
   -- Define Standard Core Attributes
   local schema = coreObjectDataDefinitionAttr()

   -- Add Custom Fields for the dataDefinition object
   schema.vars.schemaName = {type = "C"}
   schema.vars.schemaVersion = {type = "C"}
   -- Return schema
   return schema
end


-- Return standard Core Object for Data Definition attributes
coreObjectDataDefinitionAttr = function()
   -- Declare table structure
   local result = {
      vars = {
         -- Standard fields
         key = {type = "C"}
         , objectId = {type = "C"}
         , sourceSystemCd = {type = "C"}
         , name = {type = "C"}
         , description = {type = "C"}
         , creationTimeStamp = {type = "C"}
         , modifiedTimeStamp = {type = "C"}
         , createdBy = {type = "C"}
         , modifiedBy = {type = "C"}
         , itemsCount = {type = "N"}
         , createdInTag = {type = "C"}
         , sharedWithTags = {type = "C"}
      }
   }

   -- Return table structure
   return result
end

return M
