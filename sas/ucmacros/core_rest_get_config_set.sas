/*
 Copyright (C) 2022 SAS Institute Inc. Cary, NC, USA
*/

/**
   \file
\anchor core_rest_get_config_set

   \brief   Retrieve the configuration sets registered in SAS Risk Cirrus Objects

   \param [in] host Host url, including the protocol
   \param [in] port Server port (Default: 443)
   \param [in] server Name that provides the REST service (Default: riskCirrusObjects)
   \param [in] logonHost (Optional) Host/IP of the sas-logon-app service or ingress.  If blank, it is assumed that the sas-logon-app host/ip is the same as the host/ip in the url parameter 
   \param [in] logonPort (Optional) Port of the sas-logon-app service or ingress.  If blank, it is assumed that the sas-logon-app port is the same as the port in the url parameter
   \param [in] username Username credentials
   \param [in] password Password credentials: it can be plain text or SAS-Encoded (it will be masked during execution).
   \param [in] authMethod: Authentication method (accepted values: BEARER). (Default: BEARER).
   \param [in] client_id The client id registered with the Viya authentication server. If blank, the internal SAS client id is used (only if GRANT_TYPE = password).
   \param [in] client_secret The secret associated with the client id.
   \param [in] sourceSystemCd The source system code to assign to the object when registering it in Cirrus Objects (Default: 'blank').
   \param [in] solution The solution short name from which this request is being made. This will get stored in the createdInTag and sharedWithTags attributes on the object (Default: 'blank').
   \param [in] configSetId Object Id filter to apply on the GET request when a value for key is specified.
   \param [in] filter Filters to apply on the GET request when no value for key is specified. (e.g. eq(objectId,'ConfigSet-2022.1.4' | and(eq(name,'Configuration Set for Core'),eq(modifiedBy,'sasadm')) )
   \param [in] start Specify the starting point of the records to get. Start indicate the starting index of the subset. Start SHOULD be a zero-based index. The default start SHOULD be 0. Applicable only when a filter is used.
   \param [in] limit Limit controls the maximum number of items to get from the start position (Default = 1000). Applicable only when a filter is used.
   \param [in] debug True/False. If True, debugging informations are printed to the log (Default: false)
   \param [in] logOptions Logging options (i.e. mprint mlogic symbolgen ...)
   \param [in] restartLUA. Flag (Y/N). Resets the state of Lua code submission for a SAS session if set to Y (Default: Y)
   \param [in] clearCache Flag (Y/N). Controls whether the connection cache is cleared across multiple proc http calls. (Default: Y)
   \param [out] outds Name of the output table that contains the allocation schemes (Default: link_types)
   \param [out] outVarToken Name of the output macro variable which will contain the access token (Default: accessToken)
   \param [out] outSuccess Name of the output macro variable that indicates if the request was successful (&outSuccess = 1) or not (&outSuccess = 0). (Default: httpSuccess)
   \param [out] outResponseStatus Name of the output macro variable containing the HTTP response header status: i.e. HTTP/1.1 200 OK. (Default: responseStatus)

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

   2) Send a Http GET request and parse the JSON response into the output table work.configuration_sets
   \code
      %let accessToken =;
      %core_rest_get_config_set(host = <host>
                                  , port = <port>
                                  , server = riskCirrusObjects
                                  , logonHost =
                                  , logonPort =
                                  , username =
                                  , password =
                                  , authMethod = bearer
                                  , client_id =
                                  , client_secret =
                                  , SourceSystemCd =
                                  , solution =
                                  , configSetId = ConfigSet-2022.1.4
                                  , filter =
                                  , start = 0
                                  , limit = 100
                                  , logSeverity = WARNING
                                  , outds = work.configuration_sets
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

   |                  key                  |           objectId         | sourceSystemCd |            name            |           description        |     creationTimeStamp    |      modifiedTimeStamp   | createdBy | modifiedBy | createdInTag | mediaTypeVersion |
   |---------------------------------------|----------------------------|----------------|----------------------------|------------------------------|--------------------------|--------------------------|-----------|------------|--------------|------------------|
   | b904693c-235e-4f05-a9a1-f2aa4cdbdc2d  | ConfigSet-2022.1.4         | RCC            | Configuration Set for Core | Config set for Core solution | 2022-07-02T15:37:48.044Z | 2022-07-02T15:37:48.926Z | sasadm    | sasadm     | CORE         | 1                |

   \ingroup rgfRestUtils

   \author  SAS Institute Inc.
   \date    2022
*/


%macro core_rest_get_config_set(host =
                                  , port = 443
                                  , server = riskCirrusObjects
                                  , logonHost =
                                  , logonPort =
                                  , username =
                                  , password =
                                  , authMethod = bearer
                                  , client_id =
                                  , client_secret =
                                  , sourceSystemCd = RCC
                                  , solution =
                                  , configSetId =                       /* Config Set Id to filter i.e ConfigSet-2022.1.4 */
                                  , filter =                            /* add any other filters */
                                  , start =
                                  , limit = 1000
                                  , logSeverity = WARNING
                                  , outds = work.configuration_sets
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
    ;

    /* Set the required log options */
    %if(%length(&logOptions.)) %then
    options &logOptions.;
    ;

    /* Get the current value of mlogic and symbolgen options */
    %local oldLogOptions;
    %let oldLogOptions = %sysfunc(getoption(mlogic)) %sysfunc(getoption(symbolgen));

    %if (%sysevalf(%superq(solution) eq, boolean)) %then %do;
        %put ERROR: Parameter 'solution' is required.;
        %return;
    %end;

    %if (%sysevalf(%superq(sourceSystemCd) eq, boolean)) %then %do;
        %put ERROR: Parameter 'sourceSystemCd' is required.;
      %return;
    %end;

    %if(%length(&port.) = 0) %then
        %let port = 443;

    %let requestUrl = &host:&port.;
    
    /* Set the base Request URL */
    %if (%sysevalf(%superq(host) eq, boolean)) %then %do;
        %let requestUrl = %sysget(SAS_SERVICES_URL);
    %end;

    %let requestUrl = &requestUrl./&server./objects/configurationSets;

    /* Add filters (if any) */
    %if (%sysevalf(%superq(filter) eq, boolean)) %then %do;
        %let requestUrl = &requestUrl.?filter=or(eq(createdInTag,%27&solution.%27),contains(sharedWithTags,%27&solution.%27));
    %end;
    %else %do;
            %local filterIn;
            /* remove substring 'filter=' if exists */
            %let filterIn = %sysfunc(prxchange(s/\bfilter=\b//i, -1, %superq(filter)));
            %let requestUrl = &requestUrl.?filter=and(&filterIn.,or(eq(createdInTag,%27&solution.%27),contains(sharedWithTags,%27&solution.%27)));
    %end;

    %let requestUrl = &requestUrl.%nrstr(&)sourceSystemCd=&sourceSystemCd.;

    %if(%sysevalf(%superq(configSetId) ne, boolean)) %then %do;
        %let requestUrl = &requestUrl.%nrstr(&)objectId=&configSetId.;
    %end;

    /* Set Start and Limit options */
    %if(%sysevalf(%superq(start) ne, boolean)) %then
        %let requestUrl = &requestUrl.%nrstr(&)start=&start.;
    %if(%sysevalf(%superq(limit) ne, boolean)) %then
        %let requestUrl = &requestUrl.%nrstr(&)limit=&limit.;

    /*%put &=requestUrl;*/
    
    filename respSets temp;

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
                    , fout = respSets
                    , parser = sas.risk.cirrus.core_rest_parser.coreRestConfigSet
                    , outds = &outds.
                    , outVarToken = &outVarToken.
                    , outSuccess = &outSuccess.
                    , outResponseStatus = &outResponseStatus.
                    , debug = &debug.
                    , logOptions = &oldLogOptions.
                    , restartLUA = &restartLUA.
                    , clearCache = &clearCache.
                    );

    %if ((not &&&outSuccess..) or not(%rsk_dsexist(&outds.)) or %rsk_attrn(&outds., nobs) = 0) %then %do;
         %put ERROR: the request to get the configurationSet failed.;
         %return;
    %end;

    libname resp_set json fileref=respSets noalldata nrm;
    
    data &outds;
        set resp_set.items end=last;
        call symputx("object_key", key, "L");

        if not missing(key) then do;
            call symputx("ObjectId", ObjectId, "L");
        end;
        if last and not missing(key) then call symputx("num_keys", _N_, "L");
    run;

    %if %upcase(&debug) ne TRUE %then %do;
        filename respSets CLEAR;
    %end;

    %put configSet_object_key:= &object_key.;
    %put configSet_num_keys:= &num_keys.;

    /* Exit if 2 or more object instances met the objectFilter*/
    %if &num_keys. gt 1 and %sysevalf(%superq(configSetId) eq, boolean) %then %do;
        %put ERROR: More than 1 instance was found for object type "&configSetId.";
        %return;
    %end;

    %if "&object_key"="." %then %do;
        %put ERROR: No instances were found for object type "&configSetId.";
        %return;
    %end;
    %else %do;
        %put Note: Create new json file with typeData;
    %end;

%mend core_rest_get_config_set;