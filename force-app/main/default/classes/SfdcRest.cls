public inherited sharing class SfdcRest {
    //took some of this from https://www.jitendrazaa.com/blog/salesforce/call-salesforce-rest-api-from-apex/
    //Keep in mind that we can only make 100 callouts in a single execution context:
    //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void deleteDashboard(String pDashboardId){
        //yes! you can call this as a Syad on another user even if that user is inactive!!!!!
        //https://developer.salesforce.com/docs/atlas.en-us.api_analytics.meta/api_analytics/analytics_api_dashboard_delete.htm
        //example: /services/data/v34.0/analytics/dashboards/01ZD00000007S89MAE
        //Make sure your Salesforce instance URL is added in remote site settings
        // Make sure you're doing defensive programming (dappleman)
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = sfdcURL + '/services/data/v49.0/analytics/dashboards/'+ pDashboardId; 
        deleteAnalyitcRestCall(restAPIURL);
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    private static void deleteAnalyitcRestCall(String pEndPoint){
        //this was specifically written for the deletion of Reports and Dashboards which are known to return a 204 when successful.
        //I'm uncertain if 204 is common amongst other DELETE calls
        HttpRequest httpRequest = new HttpRequest(); 
        httpRequest.setMethod('DELETE');  
        //UserInfo.getSessionId() might work fine with execute anonymous, but, lightning sessionIds don't make callouts
        //whereas Visualforce sessionIds do
        httpRequest.setHeader('Authorization', 'OAuth ' + fetchUserSessionId());    
        httpRequest.setEndpoint(pEndPoint); 
        try { 
            Http http = new Http();  
            HttpResponse httpResponse = http.send(httpRequest); 
            System.debug(LoggingLevel.warn, 'httpResponse.getStatusCode(): '+ httpResponse.getStatusCode()); 
            if (httpResponse.getStatusCode() == 204 ) { 
               //We're golden! Do nothing
            } else { 
                System.debug(LoggingLevel.warn, 'DARC alleged failure httpResponse ' + httpResponse.getBody() ); 
                //dont throw, instead move to next and throw at the end???????
                throw new CalloutException( httpResponse.getBody() ); 
            }  
        } catch( System.Exception ex) { 
            System.debug(LoggingLevel.warn, 'DARC Caught ERROR: '+ ex); 
            throw ex; 
        } 
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
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Note that moving reports on a trigger probably wouldn't work as it would have to be in the after User update, 
    //and by the time we inactivated the user, we would not be able to move the reports
    //MOVE REPORT NOTES
    //I'm seeing that this guy says if you can get these reports into a public folder, you can mass delete them
    //Keep in mind that If I can get them into a common folder, the mass delete tool can delete them for me!
    //https://sf9to5.com/2017/10/11/salesforce-mass-report-mover/
    //SFDC_BASE_URL = "https://{0}.salesforce.com"
    //SFDC_SERVICE_URL = "https://{0}.salesforce.com/services/data/v{1}"
    // vs our earlier calls services/data/v49.0/analytics/dashboards/
    //hmmm, looks like he's making a PATCH call...  
 /////////////////////////////////////////////////////////////////////////////////////////////////////
    //yeah, I don't think this is going to work for private reports if you're not logged in as that user
    // public static void moveReport(String pReportId, String pReportName, String pDestinationFolderId){
    //     Map<String, Map<String,String>> myMap = new Map<String, Map<String,String>>();
    //     myMap.put('reportMetadata', new Map<String,String>());
    //     myMap.get('reportMetadata').put('name', pReportName);
    //     myMap.get('reportMetadata').put('folderId', pDestinationFolderId);
    //     String body = Json.serialize(myMap);
    //     String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
    //     String restAPIURL = sfdcURL + '/services/data/v49.0/analytics/reports/'+ pReportId;
    //     patchAnalyitcRestCall(restAPIURL, body);
    // }
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // private static void patchAnalyitcRestCall(String pEndPoint, String pBody){
    //     System.debug('SR.PARC pEndpoint: '+pEndpoint);
    //     System.debug('SR.PARC pBody: '+pBody);
    //     //here's one example of a patch
    //     //https://blog.bessereau.eu/assets/pdfs/salesforce_analytics_rest_api.pdf
    //     //this example puts everything in JSON format
    //     //which, ends up throwing the following error:
    //     //[{"errorCode":"UNSUPPORTED_MEDIA_TYPE","message":"The Analytics API only supports JSON content type in both request and response bodies. Specify requests with content type as application/​json."}]
    //     //Note however if I perform this "same" request in workbench, it works perfectly (for my own private reports)
    //     //If I attempt to execute this command for another user's reports (either here or in workbench), I end up getting the following error:
    //     //[{"errorCode":"UNSUPPORTED_MEDIA_TYPE","message":"The Analytics API only supports JSON content type in both request and response bodies. Specify requests with content type as application/​json."}]
    //     //I could spend more time attempting to perfect this move method, but, if it doesn't get me to my end goal, what's the point?
    //     HttpRequest httpRequest = new HttpRequest(); 
    //     httpRequest.setMethod('PATCH');  
    //     httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());       
    //     httpRequest.setEndpoint(pEndPoint); 
    //     httpRequest.setBody(pBody);
        
    //     try { 
    //         Http http = new Http();  
    //         HttpResponse httpResponse = http.send(httpRequest); 
    //         if (httpResponse.getStatusCode() == 204 ) { 
    //             //do nothing
    //             System.debug(LoggingLevel.warn, 'patch callout success' ); 
    //         } else { 
    //             System.debug(LoggingLevel.warn, 'patch alleged failure httpResponse ' + httpResponse.getBody() ); 
    //             //dont throw, instead move to next?
    //             throw new CalloutException( httpResponse.getBody() ); 
    //         }  
    //     } catch( System.Exception e) { 
    //         System.debug(LoggingLevel.warn, 'Caught patch ERROR: '+ e); 
    //         throw e; 
    //     } 
    //}
 }