/*
 Copyright (C) 2022 SAS Institute Inc. Cary, NC, USA
*/

/**
   \file
\anchor core_rest_get_config_table

   \brief   Retrieve the configuration table(s) registered in SAS Risk Cirrus Objects

   \param [in] host Host url, including the protocol
   \param [in] port Server port (Default: 443)
   \param [in] server Name that provides the REST service (Default: riskCirrusObjects)
   \param [in] logonHost (Optional) Host/IP of the sas-logon-app service or ingress.  If blank, it is assumed that the sas-logon-app host/ip is the same as the host/ip in the url parameter.
   \param [in] logonPort (Optional) Port of the sas-logon-app service or ingress.  If blank, it is assumed that the sas-logon-app port is the same as the port in the url parameter.
   \param [in] username Username credentials.
   \param [in] password Password credentials: it can be plain text or SAS-Encoded (it will be masked during execution).
   \param [in] authMethod: Authentication method (accepted values: BEARER). (Default: BEARER).
   \param [in] client_id The client id registered with the Viya authentication server. If blank, the internal SAS client id is used (only if GRANT_TYPE = password).
   \param [in] client_secret The secret associated with the client id.
   \param [in] sourceSystemCd The source system code to assign to the object when registering it in Cirrus Objects (Default: 'blank').
   \param [in] solution The solution short name from which this request is being made. This will get stored in the createdInTag and sharedWithTags attributes on the object (Default: 'blank').
   \param [in] configSetId Object Id filter to apply on the GET request when a value for key is specified.
   \param [in] filter Filters to apply on the GET request when no value for key is specified (e.g. eq(createdBy,'sasadm') | and(eq(name,'datastore_config'),eq(createdBy,'sasadm')) ).
   \param [in] configTableType name of the table object used in type
   \param [in] debug True/False. If True, debugging informations are printed to the log (Default: false).
   \param [in] start Specify the starting point of the records to get. Start indicate the starting index of the subset. Start SHOULD be a zero-based index. The default start SHOULD be 0. Applicable only when a filter is used.
   \param [in] limit Limit controls the maximum number of items to get from the start position (Default = 1000). Applicable only when a filter is used.
   \param [in] logOptions Logging options (i.e. mprint mlogic symbolgen ...)
   \param [in] restartLUA. Flag (Y/N). Resets the state of Lua code submission for a SAS session if set to Y (Default: Y).
   \param [in] clearCache Flag (Y/N). Controls whether the connection cache is cleared across multiple proc http calls. (Default: Y).
   \param [out] outds_configTablesInfo Name of the output table that contains the schema info of 'datastore_config' (Default: config_tables_info).
   \param [out] outds_configTablesData Name of the output table data contains the schema of the analysis data structure (Default: config_tables_data).
   \param [out] outVarToken Name of the output macro variable which will contain the access token (Default: accessToken).
   \param [out] outSuccess Name of the output macro variable that indicates if the request was successful (&outSuccess = 1) or not (&outSuccess = 0). (Default: httpSuccess).
   \param [out] outResponseStatus Name of the output macro variable containing the HTTP response header status: i.e. HTTP/1.1 200 OK. (Default: responseStatus).

   \details
   This macro sends a GET request to <b><i>\<host\>:\<port\>/riskCirrusObjects/objects/&collectionName./</i></b> and collects the results in the output table. \n
   See \link core_rest_request.sas \endlink for details about how to send GET requests and parse the response.

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

   2) Send a Http GET request and parse the JSON response into the output table work.configuration_tables
   \code
      %let accessToken =;
      %core_rest_get_config_table(host = <host>
                                  , port = <port>
                                  , server = riskCirrusObjects
                                  , logonHost =
                                  , logonPort =
                                  , username =
                                  , password =
                                  , authMethod = bearer
                                  , client_id =
                                  , client_secret =
                                  , sourceSystemCd = RCC
                                  , solution = CORE
                                  , filter = &objectId=datastore_config__2022_1_3
                                  , start = 0
                                  , limit = 100
                                  , configSetId = ConfigSet-2022.1.4
                                  , configTableType = datastore_config
                                  , logSeverity = WARNING
                                  , outds_configTablesInfo = work.config_tables_info
                                  , outds_configTablesData = work.config_tables_data
                                  , outVarToken = accessToken
                                  , outSuccess = httpSuccess
                                  , outResponseStatus = responseStatus
                                  , debug = false
                                  , logOptions =
                                  , restartLUA = Y
                                  , clearCache = Y
                                  );
      %put &=accessToken;
      %put &=httpSuccess;
      %put &=responseStatus;
   \endcode

   <b>Sample output:</b>

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


%macro core_rest_get_config_table(host =
                                  , port = 443
                                  , server = riskCirrusObjects
                                  , logonHost =
                                  , logonPort =
                                  , username =
                                  , password =
                                  , authMethod = bearer
                                  , client_id =
                                  , client_secret =
                                  , sourceSystemCd =
                                  , solution =
                                  , filter =                                     /* Any other global filters to json attributes */
                                  , start =
                                  , limit = 1000
                                  , configSetId =                                /* configuration Sets - objectId to filter i.e objectId=ConfigSet-2022.1.4 */
                                  , configTableType =                            /* configuration Tables - name to filter i.e datastore_config */
                                  , logSeverity = WARNING
                                  , outds_configTablesInfo = work.config_tables_info         /* configset table metainfo */
                                  , outds_configTablesData = work.config_tables_data         /* configtable structure metainfo + datainfo */
                                  , outVarToken = accessToken
                                  , outSuccess = httpSuccess
                                  , outResponseStatus = responseStatus
                                  , debug = false
                                  , logOptions =
                                  , restartLUA = Y
                                  , clearCache = Y
                                  );


   %local
   requestUrl
   object_key
   ;

   /* Set the required log options */
   %if(%length(&logOptions.)) %then
   options &logOptions.;
   ;

   /* Get the current value of mlogic and symbolgen options */
   %local oldLogOptions;
   %let oldLogOptions = %sysfunc(getoption(mlogic)) %sysfunc(getoption(symbolgen));

   %if %sysevalf(%superq(configSetId) eq, boolean) %then %do;
      %put ERROR: Parameter 'configSetId' is required;
      %return;
   %end;

   %if (%sysevalf(%superq(solution) eq, boolean)) %then %do;
      %put ERROR: Parameter 'solution' is required.;
      %return;
   %end;

   %if (%sysevalf(%superq(sourceSystemCd) eq, boolean)) %then %do;
      %put ERROR: Parameter 'sourceSystemCd' is required.;
      %return;
   %end;

   %if (%sysevalf(%superq(configTableType) eq, boolean)) %then %do;
      %put ERROR: Parameter 'configTableType' is required;
      %return;
   %end;

   %if(%length(&port.) = 0) %then
     %let port = 443;

   %let requestUrl = &host:&port.;

   /* Set the base Request URL */
   %if (%sysevalf(%superq(host) eq, boolean)) %then %do;
      %let requestUrl = %sysget(SAS_SERVICES_URL);
   %end;

   %let requestUrl = &requestUrl./&server./objects/configurationTables;

   /*%put 1 &=requestUrl;*/

   %if (%sysevalf(%superq(filter) eq, boolean)) %then %do;
      %let requestUrl = &requestUrl.?filter=and(hasObjectLinkToEq(%27&sourceSystemCd.%27,%27configurationSet_configurationTable%27,%27objectId%27,%27&configSetId.%27,0),or(eq(createdInTag,%27&solution.%27),contains(sharedWithTags,%27&solution.%27)),eq(type,%27&configTableType.%27));
   %end;
   %else %do;
         %local filterIn;
         /* remove substring 'filter=' if exists */
         %let filterIn = %sysfunc(prxchange(s/\bfilter=\b//i, -1, %superq(filter)));
         %let requestUrl = &requestUrl.?filter=and(&filterIn.,hasObjectLinkToEq(%27&sourceSystemCd.%27,%27configurationSet_configurationTable%27,%27objectId%27,%27&configSetId.%27,0),or(eq(createdInTag,%27&solution.%27),contains(sharedWithTags,%27&solution.%27)),eq(type,%27&configTableType.%27));
   %end;

   /*%put 2 &=requestUrl.;*/

   /* Set Start and Limit options */
   %if(%sysevalf(%superq(start) ne, boolean)) %then
      %let requestUrl = &requestUrl.%nrstr(&)start=&start.;
   %if(%sysevalf(%superq(limit) ne, boolean)) %then
      %let requestUrl = &requestUrl.%nrstr(&)limit=&limit.;

   filename respTabs temp;

   /* Temporary disable mlogic and symbolgen options to avoid printing of userid/pwd to the log */
   option nomlogic nosymbolgen;
   /* Send the REST request */
   %core_rest_request(url = &requestUrl.
                    , method = GET
                    , logonHost = &logonHost.
                    , logonPort = &logonPort.
                    , username = &username.
                    , password = &password.
                    , authMethod = &authMethod
                    , client_id = &client_id.
                    , client_secret = &client_secret.
                    , fout = respTabs
                    , parser = sas.risk.cirrus.core_rest_parser.coreRestConfigTable
                    , outds = &outds_configTablesInfo.
                    , arg1 = &outds_configTablesData.
                    , outVarToken = &outVarToken.
                    , outSuccess = &outSuccess.
                    , outResponseStatus = &outResponseStatus.
                    , debug = &debug.
                    , logOptions = &oldLogOptions.
                    , restartLUA = &restartLUA.
                    , clearCache = &clearCache.
                    );

   %if ( (not &&&outSuccess..) or
      not(%rsk_dsexist(&outds_configTablesInfo.)) or
      %rsk_attrn(&outds_configTablesInfo., nobs) = 0 or
      not(%rsk_dsexist(&outds_configTablesData.)) or
      %rsk_attrn(&outds_configTablesData., nobs) = 0 )
   %then %do;
      %put ERROR: the request to get the configurationTable failed.;
      %return;
   %end;

%mend core_rest_get_config_table;