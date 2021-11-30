public inherited sharing class ViewManager {
    //source: https://github.com/regarcher/MetadataMaid
    //Per Salesforce: "Using inherited sharing enables you to pass AppExchange Security Review and ensure that your privileged Apex code is not used in unexpected or insecure ways."

    @AuraEnabled(cacheable=true)
    Public static List<PublicViewWrapper> getViewsByObjectName(String pObjectType, String pSortBy, String pSortOrder){
        //the caller passes in an object type, sort field and sort order.  object type is required, sort field defaults to createddate
        //and sort order 
        List<PublicViewWrapper> lstRetVal = new List<PublicViewWrapper>();
        String strObjectType = mdmUtilClass.SanitizeString(pObjectType);
        String strSortBy = convertColumnNameToDbName(pSortBy);
        //sanitizing to prevent soql injection
        String strSortOrder = 'asc';
        if (pSortOrder!=null){
            strSortOrder = mdmUtilClass.SanitizeString(pSortOrder);
        } 
        DateTime minDateTime = getMinDate();
        String strMinDateTime = minDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        List<ListView> lstListView;
        try {
            String strQuery = 'SELECT Id, Name, DeveloperName, sObjectType, createdbyid, createdby.FirstName, createdby.LastName, lastmodifiedbyid, lastmodifiedby.FirstName, lastmodifiedby.LastName, createddate, lastmodifieddate FROM ListView where createdby.LastName != null and createddate > '+ strMinDateTime +' and sobjecttype = \''+strObjectType+'\' and createdbyid != \''+UserInfo.getUserId()+'\' and createdby.firstname != \'Automated\' order by '+strSortBy+' '+strSortOrder;
            System.debug('strQuery: '+strQuery);
            lstListView = Database.query(strQuery);
            for (ListView myLV:lstListView){
                map<String, String> mapKeytoVal = SfdcRest.getListViewDetails(myLV.sObjectType, myLV.id);
                String myScope = mapKeyToVal.get('scope');
                String myFilter = getFilterFromSoql(mapKeyToVal.get('query'));
                PublicViewWrapper myPVW = new PublicViewWrapper(String.valueof(myLV.id), myLV.name, myLV.DeveloperName, myLV.sObjectType, String.valueof(myLV.createddate), String.valueof(myLV.lastmodifieddate), String.valueOf(myLV.createdbyid), myLV.createdby.FirstName, myLV.createdby.LastName, String.valueOf(myLV.LastModifiedById), myLV.lastModifiedBy.FirstName, myLV.lastModifiedBy.LastName, myScope, myFilter);
                lstRetVal.add(myPVW);
            }
        } catch (Exception ex) {
            System.debug('DM.GVBON exception: '+ex+' stacktrace: '+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
        return lstRetVal;
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@AuraEnabled(cacheable=true)
Public static integer getViewsCountByObjectName(String pObjectType){
    //the caller passes in an object type, sort field and sort order.  object type is required, sort field defaults to createddate
    //and sort order 
    integer iCount;
    String strObjectType = mdmUtilClass.SanitizeString(pObjectType);
    DateTime minDateTime = getMinDate();
    String strMinDateTime = minDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    List<ListView> lstListView;
    try {
        iCount =  Database.countQuery('SELECT Count() from ListView where createdby.LastName != null and createddate > '+ strMinDateTime +' and sobjecttype = \''+strObjectType+'\' and createdbyid != \''+UserInfo.getUserId()+'\' and createdby.firstname != \'Automated\''); 
    } catch (Exception ex) {
        System.debug('DM.GVCBON exception: '+ex);
        throw new AuraHandledException(ex.getMessage());
    }
    return iCount;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static List<Map<String,String>> getObjectTypePicklistValues(){
        //this will most likely see a lot of modifications as I'm really uncertain what we should be showing
        //1. we only show listsViews created exactlhy 1 day after the minimun createddate as I don't want to 
        //show the ones that came with the creation of the Org.
        //2. it might be nice to omit system administrators optionally , but at this moment, I'm uncertain how I'd do that
        List<Map<String,String>> options = new  List<Map<String,String>> ();
        Set<String> setObjectApiNames = new Set<String>();
        DateTime minDateTime = getMinDate();
      
        for (ListView myLW: [select sObjectType from ListView where createdby.LastName != null and createdbyid != :UserInfo.getUserId() and namespaceprefix = null 
            and sObjectType != null and name != 'all' and createddate > :minDateTime and createdby.firstName != 'Automated' order by sobjecttype]){
            if (!myLW.sObjectType.contains('000000')){
                setObjectApiNames.add(myLW.sObjectType);
            }
        }

        Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();
        List<String> lstNames = new List<String>();
        Map<String,String> mapLabelToApiName = new  Map<String,String>();
        for (String strApiName:setObjectApiNames){
            if (sObjects.get(strApiName)!=null){
                String strLabel = sObjects.get(strApiName).getDescribe().getLabel();
                lstNames.add(strLabel);
                mapLabelToApiName.put(strLabel,strApiName);
            }
        }
        lstNames.sort();
        for (String strLabel:lstNames){
            Map < String, String > values = new Map < String, String > {
                'label' => strLabel,
                'value' => mapLabelToApiName.get(strLabel)
            };
            options.add(values);
        }
 
        return options;
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static String getFilterFromSoql(String pSoql){
        try{
            if (pSoql != null && pSoql.contains('WHERE') && pSoql.contains('ORDER')){
                //the substring +6 trims off some off the extrainious stuff no one cares about
                pSoql = pSoql.substring(pSoql.indexOfIgnoreCase('WHERE')+6, pSoql.indexOfIgnoreCase('ORDER'));
            }else{
                pSoql = null;
            }
        }catch(Exception ex){
            System.debug('VM.GFFS exception: '+ex+' stacktrace: '+ex.getStackTraceString());
        }
       
        return pSoql;
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @testVisible
    private static DateTime getMinDate(){
        DateTime minDateTime;
        DateTime dtOrgCreated = [select createddate from organization][0].createddate;
       
        // List<AggregateResult> AggregateResultList = [select min(createddate) from listview];
        // for(AggregateResult aggr:AggregateResultList){ 
        //     minDateTime = (DateTime)aggr.get('expr0');
        // }
        //adding a day, and ommiting everying before that as many list views get added on Org creation
        minDateTime = dtOrgCreated.addDays(1);
        return minDateTime;
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static void deletePublicViews(String pViewRecords){
        try{
            List<PublicViewWrapper> lstPVW = (List<PublicViewWrapper>) JSON.deserialize(pViewRecords, List<PublicViewWrapper>.class);
            if (lstPVW.size()>0){
                //https://salesforce.stackexchange.com/questions/22774/how-to-delete-list-view-from-metadata
                mdService.MetadataPort service = new mdService.MetadataPort();  
                service.SessionHeader = new mdService.SessionHeader_element();
                //service.SessionHeader.sessionId = UserInfo.getSessionId(); 
                service.SessionHeader.sessionId = fetchUserSessionId();
                //mdService.ListView listView = new mdService.ListView();
                List<String> lstString = new List<String>();
                for (PublicViewWrapper myPVW:lstPVW){
                    lstString.add(myPVW.ObjectType+'.'+myPVW.DeveloperName);   
                }
                if (!Test.isRunningTest()){
                    mdService.DeleteResult[] results = service.deleteMetadata('ListView',lstString);  
                    for (mdService.DeleteResult myRes:results){
                        System.debug('deleteRes: '+myRes.fullName+ ' success: '+myRes.success);
                        if (!myRes.success){
                            for (mdService.Error myError:myRes.errors){
                                System.debug('msg: '+myError.message+'error: '+myError);
                                if (myError.extendedErrorDetails!=null){
                                    for (mdService.ExtendedErrorDetails myEED:myError.extendedErrorDetails){
                                        System.debug('myEED: '+myEED);
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        } catch (Exception ex) {
            System.debug('VM.DPV exception: '+ex+' stacktrace: '+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   @testVisible
   private static String convertColumnNameToDbName(String pColumnName){
        //default it up front
        String strRetVal = 'CreatedDate';
        if (pColumnName == 'LinkView'){
            strRetVal = 'Name';
        }else if (pColumnName == 'LinkUser'){
            strRetVal = 'CreatedBy.LastName';
        }else if (pColumnName == 'ModLinkUser'){
            strRetVal = 'LastModifiedBy.LastName';
        }else if (pColumnName == 'LastModifiedDate'){
            strRetVal = 'LastModifiedDate';
        }else if (pColumnName == 'CreatedDate'){
            strRetVal = 'CreatedDate';
        }
        return strRetVal;
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

     //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //wrapper class
   public class PublicViewWrapper{
        @AuraEnabled public String ListViewId;
        @AuraEnabled public String Name; 
        @AuraEnabled public String DeveloperName;
        @AuraEnabled public String LinkView;
        @AuraEnabled public String ObjectType;
        @AuraEnabled public String CreatedDate;
        @AuraEnabled public String LastModifiedDate;
        @AuraEnabled public String CreatedByName;
        @AuraEnabled public String LinkUser;
        @AuraEnabled public String ModByName;
        @AuraEnabled public String ModLinkUser;
        @AuraEnabled public String Scope;
        @AuraEnabled public String Filter;
        
        Public PublicViewWrapper (String pViewId, String pName, String pDeveloperName, String pObjectType, String pViewCreatedDate, String pViewLastMod, 
                String pCreatedById, String pCreatedByFirstName, String pCreatedByLastName, String pLastModById, String pModByFirstName, String pModByLastName, String pScope, String pFilter){
            this.ListViewId = pViewId;
            this.Name = pName;
            this.DeveloperName = pDeveloperName;
            this.LinkView =  URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/o/'+pObjectType+'/list?filterName='+pViewId;
            this.ObjectType = pObjectType;
            this.CreatedDate = pViewCreatedDate;
            this.LastModifiedDate = pViewLastMod;
            this.CreatedByName = pCreatedByLastName + ', ' + pCreatedByFirstName;
            this.LinkUser =  URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pCreatedById;
            this.ModByName = pModByLastName + ', ' + pModByFirstName;
            this.ModLinkUser =  URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pLastModById;
            this.Scope = pScope;
            this.Filter = pFilter;
        }
    }
  
}