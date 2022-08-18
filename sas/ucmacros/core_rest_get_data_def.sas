/*
 Copyright (C) 2022 SAS Institute Inc. Cary, NC, USA
*/

/**
   \file
\anchor core_rest_get_data_def

   \brief   Retrieve the Data Definition(s) registered in SAS Risk Cirrus Objects

   \param [in] host Host url, including the protocol
   \param [in] port Server port (Default: 443)
   \param [in] server Name of the Web Application Server that provides the REST service (Default: riskCirrusObjects)
   \param [in] sourceSystemCd The source system code to assign to the object when registering it in Cirrus Objects (Default: 'blank').
   \param [in] solution The solution short name from which this request is being made. This will get stored in the createdInTag and sharedWithTags attributes on the object (Default: 'blank').
   \param [in] username Username credentials
   \param [in] password Password credentials: it can be plain text or SAS-Encoded (it will be masked during execution)
   \param [in] authMethod: Authentication method (accepted values: BEARER). (Default: BEARER)
   \param [in] client_id The client id registered with the Viya authentication server. If blank, the internal SAS client id is used (only if GRANT_TYPE = password).
   \param [in] client_secret The secret associated with the client id.
   \param [in] key Instance key of the Cirrus object that is fetched with this REST request. If no Key is specified, the records are fetched using filter parameters
   \param [in] filter Filters to apply on the GET request when no value for key is specified (e.g. and(eq(objectId,'RMC_FX_CONVERSION%232022.1.4'),eq(createdBy,'sasadm')) ).
   \param [in] start Specify the starting point of the records to get. Start indicate the starting index of the subset. Start SHOULD be a zero-based index. The default start SHOULD be 0. Applicable only when filter is used.
   \param [in] limit Limit controls the maximum number of items to get from the start position (Default = 1000). Applicable only when filter is used.
   \param [in] debug True/False. If True, debugging informations are printed to the log (Default: false).
   \param [in] start Specify the starting point of the records to get. Start indicate the starting index of the subset. Start SHOULD be a zero-based index. The default start SHOULD be 0. Applicable only when a filter is used.
   \param [in] limit Limit controls the maximum number of items to get from the start position (Default = 1000). Applicable only when a filter is used.
   \param [in] logOptions Logging options (i.e. mprint mlogic symbolgen ...).
   \param [in] restartLUA. Flag (Y/N). Resets the state of Lua code submission for a SAS session if set to Y (Default: Y).
   \param [in] clearCache Flag (Y/N). Controls whether the connection cache is cleared across multiple proc http calls. (Default: Y).
   \param [out] outds Name of the output table that contains the allocation schemes (Default: allocation_details).
   \param [out] outVarToken Name of the output macro variable which will contain the access token (Default: accessToken).
   \param [out] outSuccess Name of the output macro variable that indicates if the request was successful (&outSuccess = 1) or not (&outSuccess = 0). (Default: httpSuccess).
   \param [out] outResponseStatus Name of the output macro variable containing the HTTP response header status: i.e. HTTP/1.1 200 OK. (Default: responseStatus).

   \details
   This macro sends a GET request to <b><i>\<host\>:\<port\>/riskCirrusObjects/objects/dataDefinitions</i></b> and collects the results in the output table. \n
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

   2) Send a Http GET request and parse the JSON response into the output table WORK.data_definitions
   \code
      %let accessToken =;
      %core_rest_get_data_def(host =
                              , port =
                              , sourceSystemCd =
                              , solution =
                              , logonHost =
                              , logonPort =
                              , username =
                              , password =
                              , authMethod = bearer
                              , client_id =
                              , client_secret =
                              , key = 30b7809f-cf98-4490-b6ce-dcb88d8e445c
                              , filter = %nrstr(&)key=30b7809f-cf98-4490-b6ce-dcb88d8e445c
                              , start =
                              , limit =
                              , outds = _tmp_dataDef_summary
                              , outds_columns = _tmp_dataDef_details
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

   |description                  | libref | sourceSystemCd | metaLibraryNm                             | createdDttm              | objectLinks | schemaVersion  | version | engine | dataType | dimensionalPoints | schemaName          | creator | businessCategoryCd | objectId | schemaTypeCd | changeReason | columnInfo                                    | key   | itemsCount | riskTypeCd | dataCategoryCd | name                 | updater |
   |-----------------------------|--------|----------------|-------------------------------------------|--------------------------|-------------|----------------|---------|--------|----------|-------------------|---------------------|---------|--------------------|----------|--------------|--------------|-----------------------------------------------|-------|------------|------------|----------------|----------------------|---------|
   | Portfolio schema definition | RMCDR  | RMC            | SAS Risk Cirrus Core Core Data Repository | 2019-03-13T19:53:14.449Z |             | rqsst.v09.2019 | 1       | META   |          |                   | st_credit_portfolio | 10000   | ST                 | 10005    | FLAT         | Initial Save | JSON representation of the column definitions | 10005 | 1          | CREDIT     | PORTFOLIO      | Portfolio Definition | 10000   |

   \ingroup rgfRestUtils

   \author  SAS Institute Inc.
   \date    2022
*/

%macro core_rest_get_data_def(host =
                                , port = 443
                                , server = riskCirrusObjects
                                , sourceSystemCd =
                                , solution =
                                , logonHost =
                                , logonPort =
                                , username =
                                , password =
                                , authMethod = bearer
                                , client_id =
                                , client_secret =
                                , key =
                                , filter =
                                , start =
                                , limit = 1000
                                , outds = data_definitions
                                , outds_columns = data_definitions_columns
                                , outds_aggregation_config = aggregation_config
                                , outVarToken = accessToken
                                , outSuccess = httpSuccess
                                , outResponseStatus = responseStatus
                                , debug = false
                                , logOptions =
                                , restartLUA = Y
                                , clearCache = Y
                                );

   %local requestUrl;

   /* Set the required log options */
   %if(%length(&logOptions.)) %then
      options &logOptions.;
   ;

   %if (%sysevalf(%superq(solution) eq, boolean)) %then %do;
      %put ERROR: Parameter 'solution' is required.;
      %return;
   %end;

   /* Get the current value of mlogic and symbolgen options */
   %local oldLogOptions;
   %let oldLogOptions = %sysfunc(getoption(mlogic)) %sysfunc(getoption(symbolgen));

   %if(%length(&port.) = 0) %then
      %let port = 443;

   %let requestUrl = &host:&port.;
    
   /* Set the base Request URL */
   %if (%sysevalf(%superq(host) eq, boolean)) %then %do;
      %let requestUrl = %sysget(SAS_SERVICES_URL);
   %end;

   %let requestUrl = &requestUrl./&server./objects/dataDefinitions;

   %if(%sysevalf(%superq(key) ne, boolean)) %then
      /* Request the specified resource by the key */
      %let requestUrl = &requestUrl./&key.;
   %else %do;
            %if (%sysevalf(%superq(filter) eq, boolean)) %then %do;
               %put ERROR: Either a query 'key' or 'filter' is required;
               %return;
            %end;
            %else %do;
               %local filterIn;
               /* remove substring 'filter=' if exists */
               %let filterIn = %sysfunc(prxchange(s/\bfilter=\b//i, -1, %superq(filter)));
               %let requestUrl = &requestUrl.?filter=and(&filterIn.,or(eq(createdInTag,%27&solution.%27),contains(sharedWithTags,%27&solution.%27)));
               
               %if(%sysevalf(%superq(sourceSystemCd) ne, boolean)) %then
                  %let requestUrl = &requestUrl.%nrstr(&)sourceSystemCd=&sourceSystemCd.;
               /* Set Start and Limit options */
               %if(%sysevalf(%superq(start) ne, boolean)) %then
                  %let requestUrl = &requestUrl.%nrstr(&)start=&start.;
               %if(%sysevalf(%superq(limit) ne, boolean)) %then
                  %let requestUrl = &requestUrl.%nrstr(&)limit=&limit.;
               %end;
   %end;

   /*%put &=requestUrl.;*/

   filename resp_def temp;

   /* Temporary disable mlogic and symbolgen options to avoid printing of userid/pwd to the log */
   option nomlogic nosymbolgen;
   /* Send the REST request */
   %core_rest_request(url = &requestUrl.
                     , method = GET
                     , logonHost = &logonHost.
                     , logonPort = &logonPort.
                     , username = &username.
                     , password = &password.
                     , headerOut = __hout_
                     , authMethod = &authMethod.
                     , client_id = &client_id.
                     , client_secret = &client_secret.
                     , fout = resp_def
                     , parser = sas.risk.cirrus.core_rest_parser.coreRestDataDefinition
                     , outds = &outds.
                     , arg1 = &outds_columns.
                     , arg2 = &outds_aggregation_config.
                     , outVarToken = &outVarToken.
                     , outSuccess = &outSuccess.
                     , outResponseStatus = &outResponseStatus.
                     , debug = &debug.
                     , logOptions = &oldLogOptions.
                     , restartLUA = &restartLUA.
                     , clearCache = &clearCache.
                     );
                     
   libname resp_def json fileref=resp_def noalldata nrm;

   %if %upcase(&debug) ne TRUE %then %do;
      libname resp_def;
      filename resp_def CLEAR;
   %end;


%mend core_rest_get_data_def;