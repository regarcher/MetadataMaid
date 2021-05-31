public inherited sharing class SfdcRest {
    //source: https://github.com/regarcher/MetadataMaid
    //I took some of this from https://www.jitendrazaa.com/blog/salesforce/call-salesforce-rest-api-from-apex/
    //Keep in mind that we can only make 100 callouts in a single execution context:
    //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    public static boolean deleteDashboard(String pDashboardId){
        //yes! you can call this as a Syad on another user even if that user is inactive!!!!!
        //https://developer.salesforce.com/docs/atlas.en-us.api_analytics.meta/api_analytics/analytics_api_dashboard_delete.htm
        //example: /services/data/v34.0/analytics/dashboards/01ZD00000007S89MAE
        //Make sure your Salesforce instance URL is added in remote site settings
        // Make sure you're doing defensive programming (dappleman)
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = sfdcURL + '/services/data/v51.0/analytics/dashboards/'+ pDashboardId; 
        return deleteRestCall(restAPIURL);
    }
    /////////////////////////////////////////////////////////////////////////////////////////////
    public static map<String, String> getListViewDetails(String pObjectType, String pViewId){
        map<String, String> mapKeyToVal = new map<String, String>();
        Http httpCall = new Http();
        HttpRequest restRequest = new HttpRequest();
        HttpResponse restResponse;
        String responseBody;
        restRequest.setTimeout(120000);
        String sessionId = fetchUserSessionId();
        String strDomain = Url.getSalesforceBaseUrl().toExternalForm();
        String strEndpoint = strDomain + '/services/data/v51.0/sobjects/' + pObjectType + '/listviews/' + pViewId + '/describe';
        restRequest.setEndpoint(strEndpoint);
        restRequest.setMethod('GET');
        restRequest.setHeader('Content-Type', 'application/json');
        restRequest.setHeader('Authorization', 'Bearer '+ sessionId);
        restResponse = httpCall.send(restRequest);
        responseBody = restResponse.getBody();
        Map<String, Object> mapKeyToObj = (Map<String, Object>)JSON.deserializeUntyped(responseBody);  
        for(String key : mapKeyToObj.keyset()) { 
            if (key=='query'){
                mapKeyToVal.put(key, (String)mapKeyToObj.get(key));
            }else if (key=='scope'){
                mapKeyToVal.put(key, (String)mapKeyToObj.get(key));
            }
        } 
        
        return mapKeyToVal;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    private static boolean deleteRestCall(String pEndPoint){
        //this was specifically written for the deletion of Reports and Dashboards which are known to return a 204 when successful.
        //I'm uncertain if 204 is common amongst other DELETE calls
        System.debug(LoggingLevel.warn, 'SFDR.DRC pEndPoint: '+pEndPoint); 
        boolean bSuccess = true;
        HttpRequest httpRequest = new HttpRequest(); 
        httpRequest.setMethod('DELETE');  
        //UserInfo.getSessionId() might work fine with execute anonymous, but, lightning sessionIds don't make callouts
        //whereas Visualforce sessionIds do
        httpRequest.setHeader('Authorization', 'OAuth ' + fetchUserSessionId());    
        httpRequest.setEndpoint(pEndPoint); 
        try { 
            Http http = new Http();  
            HttpResponse httpResponse = http.send(httpRequest); 
            System.debug(LoggingLevel.warn, 'SFDR.DRC httpResponse.getStatusCode(): '+ httpResponse.getStatusCode()); 
            if (httpResponse.getStatusCode() == 204 ) { 
               //We're golden! Do nothing
            } else { 
                System.debug(LoggingLevel.warn, 'SFDR.DRC alleged failure httpResponse ' + httpResponse.getBody() ); 
                //dont throw, instead move to next and throw at the end???????
                throw new CalloutException( httpResponse.getBody() ); 
            }  
        } catch( System.Exception ex) { 
            System.debug(LoggingLevel.warn, 'SFDR.DRC Caught ERROR: '+ ex); 
            throw ex; 
        } 
        return bSuccess;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @testVisible
    private static String fetchUserSessionId(){
        //This URL was quite helpful: https://sfdcpanther.wordpress.com/2018/02/05/how-to-call-salesforce-api-from-lightning-component/
        String sessionId = '';
        PageReference sessionPage = Page.GetSessionIdVF;
        String vfContent;
        if (Test.isRunningTest()){
            vfContent = 'Start_Of_Session_Id12345End_Of_Session_Id';
        }else{
            vfContent = sessionPage.getContent().toString();
        }
       
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
        endP = vfContent.indexOf('End_Of_Session_Id');
        sessionId = vfContent.substring(startP, endP);
        return sessionId;
    }
    
 }