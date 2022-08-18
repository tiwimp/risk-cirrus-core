/*
 Copyright (C) 2022 SAS Institute Inc. Cary, NC, USA
*/

/**
   \file
\anchor core_rest_create_analysisdata

   \brief   Create an analysis data instance in SAS Risk Cirrus objects, and create an associated Data Definition if none already exists with the given schema name and version

   \param [in] host Host url, including the protocol.
   \param [in] port Server port (Default: 443).
   \param [in] server Name that provides the REST service (Default: riskCirrusObjects).
   \param [in] logonHost (Optional) Host/IP of the sas-logon-app service or ingress.  If blank, it is assumed that the sas-logon-app host/ip is the same as the host/ip in the url parameter.
   \param [in] logonPort (Optional) Port of the sas-logon-app service or ingress.  If blank, it is assumed that the sas-logon-app port is the same as the port in the url parameter.
   \param [in] authMethod: Authentication method (accepted values: BEARER). (Default: BEARER).
   \param [in] client_id The client id registered with the Viya authentication server. If blank, the internal SAS client id is used (only if GRANT_TYPE = password).
   \param [in] client_secret The secret associated with the client id.
   \param [in] sourceSystemCd The source system code to assign to the object when registering it in Cirrus Objects (Default: 'blank').
   \param [in] solution The solution short name from which this request is being made. This will get stored in the createdInTag and sharedWithTags attributes on the object (Default: 'blank').
   \param [in] schemaName The schema name is the analysis data name.
   \param [in] schemaVersion The schema name is the analysis data name.
   \param [in] configSetId Object Id filter to apply on the GET request when a value for key is specified.
   \param [in] ovrDatastoreConfig customized datastore config table. It tends to have the same structure as the datastore config to register analysis data instances in Cirrus Core (e.g. work.datastore_config).
   \param [in] locationType The type of server location from which data will be imported. Currently, only DIRECTORY and LIBNAME are supported; support for other options is planned.
   \param [in] location The server location from which data will be imported. Interpretation of this parameter varies based on the value of locationType. When DIRECTORY, the filesystem path on the server where the import data is located. When LIBNAME, the name of the library in which the import data may be found.
   \param [in] fileName Name of the file or table from which data will be imported.
   \param [in] debug True/False. If True, debugging informations are printed to the log (Default: false).
   \param [in] logOptions Logging options (i.e. mprint mlogic symbolgen ...).
   \param [in] restartLUA. Flag (Y/N). Resets the state of Lua code submission for a SAS session if set to Y (Default: Y).
   \param [in] clearCache Flag (Y/N). Controls whether the connection cache is cleared across multiple proc http calls. (Default: Y).
   \param [out] outds_configTablesInfo Name of the output table that contains the schema info of 'datastore_config' (Default: config_tables_info).
   \param [out] outds_configTablesData Name of the output table data contains the schema of the analysis data structure (Default: config_tables_data).
   \param [out] outVarToken Name of the output macro variable which will contain the access token (Default: accessToken).
   \param [out] outSuccess Name of the output macro variable that indicates if the request was successful (&outSuccess = 1) or not (&outSuccess = 0). (Default: httpSuccess).
   \param [out] outResponseStatus Name of the output macro variable containing the HTTP response header status: i.e. HTTP/1.1 200 OK. (Default: responseStatus).

   \details
   This macro sends a POST request to <b><i>\<host\>:\<port\>/riskData/objects?locationType=&locationType.&location=&location.&fileName=&filename/</i></b> and collects the results in the output table. \n
   See \link core_rest_request.sas \endlink for details about how to send GET/POST requests and parse the response.

   <b>Example:</b>

   1) Set up the environment (set SASAUTOS and required LUA libraries).  Assumes the spre folder is under /riskcirruscore/core/code_libraries/release-core-2022.1.4
   \code
      %let core_root_path=/riskcirruscore/core/code_libraries/release-core-2022.1.4;
      option insert = (
         SASAUTOS = (
            "&core_root_path./spre/sas/ucmacros"
            )
         );
      filename LUAPATH ("&core_root_path./spre/lua");
   \endcode

   2) Send a Http GET request and parse the JSON response into the outputs tables work.configuration_tables_info and work.configuration_tables_data
   \code
      %let accessToken =;
      %core_rest_create_analysisdata(host =
                              , port =
                              , server = riskCirrusObjects
                              , logonHost =
                              , logonPort =
                              , authMethod = bearer
                              , client_id =
                              , client_secret =
                              , solution =
                              , sourceSystemCd =
                              , schemaName = RMC_FX_CONVERSION
                              , schemaVersion = 2022.1.4
                              , configSetId = ConfigSet-2022.1.4
                              , ovrDatastoreConfig =
                              , locationType = DIRECTORY
                              , location = /riskcirruscore/core2/code_libraries/release-core-2022.1.4/tables
                              , fileName = fx_conversion
                              , logSeverity = WARNING
                              , outds_configTablesInfo = work.config_tables_info
                              , outds_configTablesData = work.config_tables_data
                              , outVarToken = accessToken
                              , outSuccess = httpSuccess
                              , outResponseStatus = responseStatus
                              , debug = true
                              , logOptions =
                              , restartLUA = Y
                              , clearCache = Y);
      %put &=httpSuccess;
      %put &=responseStatus;
   \endcode

   <b>Sample output outds_configTablesInfo: </b>

   |      key                              |        name       |           versionNm        | createdInTag |   description    | statusCd | sourceSystemCd | sharedWithTags |           objectId          | type              |
   |---------------------------------------|-------------------|----------------------------|--------------|------------------|----------|----------------|----------------|-----------------------------|-------------------|
   | e7a2a66d-e326-4f1c-8ab7-28d12a1a5c67  | datastore_config  |            2022.1.4        | CORE         | datastore_config | TEST     | RCC            | CORE           | datastore_config__2022_1_3  | datastore_config  |

   <b>Sample output outds_configTablesData: </b>

   |details_app           | rule_set_group_id | schema_name          | rule_set_desc    | risk_typ    | schema_type  | rls_table_name  | lasr_meta_folder  | fx_vars                                     | mart_table_name | schema_version    | index_list |  libref | attributable_vars                              | analysis_data_name                     | constraint_enabled_flg |  results_category	| primary_key         | data_type   | datastore_group_id | analysis_data_desc	                  | rule_set_name             | business_key   | custom_code  | classification_vars | reportmart_group_id | cas_library_name  | details_root             | data_definition_name | data_definition_desc        | mandatory_segmentation_vars | casr_library_name  | business_category  | dimension_list  | table_name       | partition_vars        | data_sub_category | mart_library_name  | meta_library_name  | rule_set_category  | filterable_vars                         | type2_cols | projection_vars | data_category  |
   |----------------------|-------------------|----------------------|------------------|-------------|--------------|---------------- |-------------------|---------------------------------------------|-----------------|-------------------|------------|---------|------------------------------------------------|----------------------------------------|------------------------|---------------------|---------------------|-------------|--------------------|--------------------------------------|---------------------------|----------------|--------------|---------------------|---------------------|-------------------|--------------------------|----------------------|-----------------------------|-----------------------------|--------------------|--------------------|-----------------|------------------|-----------------------|-------------------|--------------------|--------------------|--------------------|-----------------------------------------|------------|-----------------|----------------|
   |SASRiskManagementCore | CREDIT_PORTFOLIO  | RMC_CREDIT_PORTFOLIO | Data Quality ... | CREDIT      | FLAT         |                 |                   | ACCRUED_INTEREST_AMT AMORTIZED_COST_AMT ... |                 | &content_version. |            | RCC_STG | PD_SEGMENT_ID LGD_SEGMENT_ID LR_SEGMENT_ID ... | Portfolio <MONTH, 0, SAME, yymmddd10.> | Y                      |                     | REPORTING_DT INSTID |             | Enrichment         | Portfolio data for the base date ... | Portfolio DQ Rule Set ... |                |              |                     |                     | &cas_library_name.| &sas_risk_workgroup_dir. | Portfolio Definition | Portfolio schema definition |                             |                    | ALL                |                 | CREDIT_PORTFOLIO | REPORTING_DT INSTTYPE |                   |                    |                    | DQ                 | PORTFOLIO_SEGMENT ACCOUNTING_METHOD ... |            |                 | PORTFOLIO      |

   \ingroup rgfRestUtils

   \author  SAS Institute Inc.
   \date    2022
*/

%macro core_rest_create_analysisdata(host =
                              , port = 443
                              , server = riskCirrusObjects
                              , logonHost =
                              , logonPort =
                              , authMethod = bearer
                              , client_id =
                              , client_secret =
                              , solution =
                              , sourceSystemCd =
                              , schemaName =
                              , schemaVersion =
                              , configSetId =
                              , ovrDatastoreConfig =
                              , locationType = DIRECTORY
                              , location =
                              , fileName =
                              , logSeverity =
                              , outds_configTablesInfo = work.config_tables_info
                              , outds_configTablesData = work.config_tables_data
                              , outVarToken =
                              , outSuccess =
                              , outResponseStatus =
                              , debug =
                              , logOptions =
                              , restartLUA = Y
                              , clearCache = Y);

   %local requestUrl
       alltogether
       uniqueTogether
       primary_key
       filterable_vars
       partition_vars
       attributable_vars
       mandatory_segmentation_vars
       fx_vars
       classification_vars
       projection_vars
       data_definition_name
       data_definition_desc
       table_name
       analysis_data_name
       analysis_data_desc
       index_list
       i
       word
       contaVars
       analysisDataVarsScope;

   %if(%length(&port.) = 0) %then
      %let port = 443;

   %let requestUrl = &host:&port.;
    
   /* Set the base Request URL */
   %if (%sysevalf(%superq(host) eq, boolean)) %then %do;
      %let requestUrl = %sysget(SAS_SERVICES_URL);
   %end;

   %let requestUrl = &requestUrl./riskData/objects?locationType=&locationType.%nrstr(&)location=&location.%nrstr(&)fileName=&fileName.;

   %if (%sysevalf(%superq(schemaName) eq, boolean)) %then %do;
      %put ERROR: Parameter 'schemaName' is required.;
      %return;
   %end;

   %if (%sysevalf(%superq(schemaVersion) eq, boolean)) %then %do;
      %put ERROR: Parameter 'schemaVersion' is required.;
      %return;
   %end;

   %if (%sysevalf(%superq(solution) eq, boolean)) %then %do;
      %put ERROR: Parameter 'solution' is required.;
      %return;
   %end;

   %if (%sysevalf(%superq(locationType) eq, boolean)) %then %do;
      %put ERROR: The 'locationType' parameter is required. Available values : DIRECTORY, LIBNAME, FOLDER;
      %return;
   %end;

   %if (%sysevalf(%superq(location) eq, boolean)) %then %do;
      %put ERROR: The 'location' parameter is required.;
      %return;
   %end;

   %if (%sysevalf(%superq(fileName) eq, boolean)) %then %do;
      %put ERROR: The 'fileName' parameter is required.;
      %return;
   %end;

   %if (%sysevalf(%superq(ovrDatastoreConfig) eq, boolean)) %then %do;
      /* Get configuration table information */
      %core_rest_get_config_table(host = &host.
                                    , port = &port.
                                    , server = &server.
                                    , authMethod = &authMethod.
                                    , client_id = &client_id.
                                    , client_secret = &client_secret.
                                    , sourceSystemCd = &sourceSystemCd.
                                    , solution = &solution.
                                    , configSetId = &configSetId.
                                    , configTableType = datastore_config
                                    , logSeverity = &logSeverity.
                                    , outds_configTablesInfo = &outds_configTablesInfo.
                                    , outds_configTablesData = &outds_configTablesData.
                                    , outVarToken = &outVarToken.
                                    , outSuccess = &outSuccess.
                                    , outResponseStatus = &outResponseStatus.
                                    , debug = &debug.
                                    , logOptions = &logOptions.
                                    , restartLUA = &restartLUA.
                                    , clearCache = &clearCache.
                                    );
   %end;
   %else %do;
         /* Build a step to load user table structure */
         %if ( not(%rsk_dsexist(&ovrDatastoreConfig.)) or %rsk_attrn(&ovrDatastoreConfig., nobs) = 0 ) %then %do;
            %put ERROR: Configuration table '&ovrDatastoreConfig.' for analysis data is required.;
            %return;
         %end;

         /* Validate all required columns necessary to write analysisDefiniton and analysisData json _body */
         %let analysisDataVarsScope = 'primary_key','filterable_vars','partition_vars','attributable_vars','mandatory_segmentation_vars','fx_vars','classification_vars','projection_vars','data_definition_name','data_definition_desc','table_name','analysis_data_name','analysis_data_desc','index_list';
         %let outds_configTablesData = &ovrDatastoreConfig.;

          /* The analysis data table should have least these 'countw("&analysisDataVarsScope.")'' vars in scope to enable data definition */
          proc contents data=&ovrDatastoreConfig. out=work.out_contents noprint; run;
          proc sql noprint;
             select count(*) into: contaVars
             from work.out_contents
             where lowcase(name) in (&analysisDataVarsScope.)
          ;quit;

          /* Exit if all the required vars in scope are not present */
          %if &contaVars. ne %sysfunc(countw("&analysisDataVarsScope.")) %then %do;
             %put ERROR: All the variables required in the scope are not present.;
             %return;
          %end;
         
          /* If customized table is meets the requirements */
          %let outds_configTablesData = &ovrDatastoreConfig.;
   %end;

   /* Get analysis data columns info to write analysisDefiniton and analysisData json _body */

   proc sql noprint;
      select upcase(strip(primary_key)
            ||' '||strip(filterable_vars)
            ||' '||strip(partition_vars)
            ||' '||strip(attributable_vars)
            ||' '||strip(mandatory_segmentation_vars)
            ||' '||strip(fx_vars)
            ||' '||strip(classification_vars)
            ||' '||strip(projection_vars))
            ,strip(primary_key)
            ,strip(filterable_vars)
            ,strip(partition_vars)
            ,strip(attributable_vars)
            ,strip(mandatory_segmentation_vars)
            ,strip(fx_vars)
            ,strip(classification_vars)
            ,strip(projection_vars)
            ,strip(data_definition_name)
            ,strip(data_definition_desc)
            ,strip(table_name)
            ,strip(analysis_data_name)
            ,strip(analysis_data_desc)
            ,strip(index_list)
            into :alltogether
               ,:primary_key
               ,:filterable_vars
               ,:partition_vars
               ,:attributable_vars
               ,:mandatory_segmentation_vars
               ,:fx_vars
               ,:classification_vars
               ,:projection_vars
               ,:data_definition_name
               ,:data_definition_desc
               ,:table_name
               ,:analysis_data_name
               ,:analysis_data_desc
               ,:index_list
      from &outds_configTablesData.
      where (upcase(schema_name)=upcase("&schemaName.")
            and upcase(schema_version)=upcase("&schemaVersion.")
            )
   ;quit; 

   %if(%sysevalf(%superq(alltogether) eq, boolean)) %then %do;
      %put ERROR: Unable to get the &schemaName..;
      %return;
   %end;

   %let uniqueTogether=;
   %do i=1 %to %sysfunc(countw(&alltogether.,%str( )));
   %let word=%scan(&alltogether.,&i,%str( ));
   %if not %sysfunc(indexw(&uniqueTogether,&word,%str( ))) %then
      %let uniqueTogether= &uniqueTogether. &word.;
   %end;

   /* Get the current value of mlogic and symbolgen options */
   %local oldLogOptions;
   %let oldLogOptions = %sysfunc(getoption(mlogic)) %sysfunc(getoption(symbolgen));

   %let query_filter = and(eq(schemaName,%27&schemaName.%27),eq(schemaVersion,%27&schemaVersion.%27));

   /* Check if the data definition already exists */

   %let &outSuccess. = 0;
   /* Temporary disable mlogic and symbolgen options to avoid printing of userid/pwd to the log */
   option nomlogic nosymbolgen;
   %core_rest_get_data_def(host = &host.
                  , port = &port.
                  , authMethod = &authMethod.
                  , client_id = &client_id.
                  , client_secret = &client_secret.
                  , solution = &solution.
                  %if(%sysevalf(%superq(sourceSystemCd) ne, boolean)) %then
                  , sourceSystemCd = &sourceSystemCd.
                  , filter = %superq(query_filter)
                  , limit = 1000
                  , outds = _tmp_dataDef_summary
                  , outds_columns = _tmp_dataDef_details
                  , outVarToken = &outVarToken.
                  , outSuccess = &outSuccess.
                  , outResponseStatus = &outResponseStatus.
                  , debug = &debug.
                  , logOptions = &oldLogOptions.
                  , restartLUA = &restartLUA.
                  , clearCache = &clearCache.
                  );

   /* Exit in case of errors */
   %if(not &&&outSuccess.. or not %rsk_dsexist(_tmp_dataDef_summary)) %then %do;
      %put ERROR: Unable to get the data definition information.;
      %return;
   %end;

   %if(%sysevalf(%superq(schemaVersion) eq, boolean)) %then %do;
      /* When schemaVersion is blank, the REST request above might return multiple objects (since we only filtered on schemaName).
      We need to apply an additional filter on the result table to check on the schemaVersion */
      data _tmp_dataDef_summary;
         set _tmp_dataDef_summary(where = (missing(schemaVersion)));
      run;
      %put ERROR: Need to apply an additional filter to check on the schemaVersion..;
      %return;
   %end;      

   /* Exit if there is more than one result */
   %if(%rsk_attrn(_tmp_dataDef_summary, nobs) > 1) %then %do;
      %put ERROR: There is more than one Data Definition matching the same &schemaName and &schemaVersion..;
      %return;
   %end;

   /* Exit if there are no data definitions matching the required schema name/version */
   %if(%rsk_attrn(_tmp_dataDef_summary, nobs) = 0) %then %do;	
      %put NOTE: Could not find any Data Definition. Can proceed with new schema name instance.;
      %let definition_key=;
   %end;
   %else %do;
      data _null_;
         set _tmp_dataDef_summary;
         call symputx('definition_key', key, 'L');
      run;
   %end;

   /*%put &=definition_key.;*/

   /* Process date directives */
   %let analysis_data_name = %core_process_date_directive(name = %superq(analysis_data_name));
   %let analysis_data_desc = %core_process_date_directive(name = %superq(analysis_data_desc));
   %let data_definition_name = %core_process_date_directive(name = %superq(data_definition_name));
   %let data_definition_desc = %core_process_date_directive(name = %superq(data_definition_desc));

   filename _body temp;

   data _null_;
      file _body recfm=N;
      length str var _attr_ $1000;
      put '{';
      put '"dataDefinition": {';
      %if (%sysevalf(%superq(definition_key) eq, boolean)) %then %do;
         str = '"name":"'||strip("&data_definition_name.")||'"'; put str;
         str = ',"description":"'||strip("&data_definition_desc.")||'"'; put str;
         str = ',"sourceSystemCd":"'||strip("&sourceSystemCd.")||'"'; put str;
         str = ',"createdInTag":"'||strip("&solution.")||'"'; put str;
         put ',"customFields": {';
         str = '"schemaName":"'||strip("&schemaName.")||'"'; put str;
         str = ',"schemaVersion":"'||strip("&schemaVersion.")||'"'; put str;

         %if (%sysevalf(%superq(index_list) ne, boolean)) %then %do;
            str = ',"defaultIndexList":"'||strip("&index_list.")||'"'; put str;
         %end;

         put ',"columnInfo": [';

         i = 1;
         do while (strip(scan(strip("&uniqueTogether."),i,' ')) ne '');
            var = strip(scan(strip("&uniqueTogether."),i,' '));
            put '{';
            str = '"name": "'||strip(var)||'"'; put str;

            _attr_=strip("&primary_key.");
            if indexw(_attr_,var) gt 0 then
               put ',"primaryKeyFlag": true';

            _attr_=strip("&filterable_vars.");
            if indexw(_attr_,var) gt 0 then
               put ',"filterable": true';

            _attr_=strip("&partition_vars.");
            if indexw(_attr_,var) gt 0 then
               put ',"partitionFlag": true';

            _attr_=strip("&attributable_vars.");
            if indexw(_attr_,var) gt 0 then
               put ',"attributable": true';

            _attr_=strip("&mandatory_segmentation_vars.");
            if indexw(_attr_,var) gt 0 then
               put ',"mandatorySegmentation": true';

            _attr_=strip("&fx_vars.");
            if indexw(_attr_,var) gt 0 then
               put ',"fxVar": true';

            _attr_=strip("&classification_vars.");
            if indexw(_attr_,var) gt 0 then
               put ',"classification": true';

            _attr_=strip("&projection_vars.");
            if indexw(_attr_,var) gt 0 then
               put ',"projection": true';

            i=i+1;
            if strip(scan(strip("&uniqueTogether."),i,' ')) ne "" then do;
               str = '},'; put str;
            end;
            else do;
               str = '}'; put str;
            end;
         end;
         put ']';
         put '}';
         put '},';
      %end; /* (%sysevalf(%superq(definition_key) eq, boolean)) */
      %else %do;
         str = '"key":"'||strip("&definition_key.")||'"'; put str;
         put '},';
      %end;

      put '"analysisData": {';
      str = '"name":"'||strip("&analysis_data_name.")||'"'; put str;
      str = ',"description":"'||strip("&analysis_data_desc.")||'"'; put str;
      str = ',"sourceSystemCd":"'||strip("&sourceSystemCd.")||'"'; put str;
      str = ',"createdInTag":"'||strip("&solution.")||'"'; put str;

      %if (%sysevalf(%superq(index_list) ne, boolean)) %then %do;
         put ',"customFields": {';
         str = '"indexList":"'||strip("&index_list.")||'"'; put str;
         put '}';
      %end;
         put '}';
         put '}';
   run;

   filename _resp temp;

   /* Temporary disable mlogic and symbolgen options to avoid printing of userid/pwd to the log */
   option nomlogic nosymbolgen;
   /* Send the REST request */
   %core_rest_request(url = &requestUrl.
                     , method = POST
                     , authMethod = &authMethod.
                     , headerIn = Accept:application/json
                     , body = _body
                     , contentType = application/json
                     , fout = _resp
                     , parser =
                     , outds = rest_request_post_response
                     , outSuccess = &outSuccess.
                     , outResponseStatus = &outResponseStatus.
                     , debug = &debug.
                     , logOptions = &oldLogOptions.
                     , restartLUA = &restartLUA.
                     , clearCache = &clearCache.
                     );

   /* Exit in case of errors */
   %if( (not &&&outSuccess..) or not(%rsk_dsexist(rest_request_post_response)) or %rsk_attrn(rest_request_post_response, nobs) = 0 ) %then %do;
      %put ERROR: Unable to request POST the data definition instance.;

      %if(%upcase(&debug.) eq TRUE) %then %do;
         libname _resp json fileref=_resp noalldata;
         data _null_;
            set _resp.root(keep=message);
            call symputx("resp_message",message);
         run;
         %put ERROR: &resp_message.;
         libname _resp;
      %end; /* %if(%upcase(&debug.) eq TRUE) */
      %return;
   %end; /* %if( (not &&&outSuccess..) */

%mend core_rest_create_analysisdata;