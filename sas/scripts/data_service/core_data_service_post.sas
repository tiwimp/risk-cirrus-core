
%macro setup_macro_lua_path(code_lib_base_path=SAS_RISK_CIRRUS_CODE_LIB_BASE_PATH_CORE,version_dir=SAS_RISK_CIRRUS_CODE_LIB_LATEST_VERSION_DIR_CORE);
   %let core_root_path=%sysget(&code_lib_base_path.);
   %let core_code_path=&core_root_path./%sysget(&version_dir.);
   option insert = ( SASAUTOS = ("&core_code_path./sas/ucmacros"));
   filename LUAPATH ("&core_code_path./lua"  "&core_root_path."  "&core_code_path.");
   %put &=core_root_path;
   %put &=core_code_path;
%mend;

%setup_macro_lua_path;

proc lua restart;
submit;

local ds = require "sas.risk.irm.core_data_service"

--Reading SAS macro vars
--fileref source lib , source ds amd targetlib from SAS env var.
local sasVarTab= { RDS_DATA_DEF_FILEREF_NAME = "",
                   RDS_INPUT_LIBREF_NAME = "",
                   RDS_INPUT_TABLE_NAME = "" ,
                   RDS_POSTGRES_LIBREF_NAME = "",
                   RDS_ANALYSIS_DATA_TABLE_NAME= ""
                   }

for i,v in pairs(sasVarTab) do
  sasVarTab[i]=sas.symget(i)
  if sasVarTab[i] == nil  or sasVarTab[i] == '' then
     error("Following macro variable is not set::"..i )
  end

end

--Converting json file to lua json object.
jsonObjectFromService=ds.rdsTransformFrefToJsonTable(sasVarTab.RDS_DATA_DEF_FILEREF_NAME)

--Reading table to get targetTableNm and partitions params.
local params=ds.rdsGetParamFromJsonTable(jsonObjectFromService)

print("****************************************************")
print("SourceLibNm",sasVarTab.RDS_INPUT_LIBREF_NAME)
print("SourceTableNm",sasVarTab.RDS_INPUT_TABLE_NAME)
print("TargetLibNm",sasVarTab.RDS_POSTGRES_LIBREF_NAME)
print("TargetTableNm",sasVarTab.RDS_ANALYSIS_DATA_TABLE_NAME)
print("PartitionParams",table.tostring(params))
print("****************************************************")

local res= ds.generatePartitions(sasVarTab.RDS_INPUT_LIBREF_NAME
                                ,sasVarTab.RDS_INPUT_TABLE_NAME
                                ,sasVarTab.RDS_POSTGRES_LIBREF_NAME
                                ,sasVarTab.RDS_ANALYSIS_DATA_TABLE_NAME
                                ,params
                                ,false )
print("Partition Return Value::")
print(res)


endsubmit;
run;