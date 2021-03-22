public inherited sharing class DashboardManager {
    //source: https://github.com/regarcher/MetadataMaid
    @AuraEnabled
    public static boolean deletePrivateDashboardsById(List<ID> pDashboardIds){
        for (ID myDBID:pDashboardIds){
            SfdcRest.deleteDashboard(myDBID);
         }
         return true;
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled(cacheable=true)
    public static Integer getPrivateDashboardsInactiveUsersCount(){
        Integer iRetVal = 0;
        try {
            iRetVal = Database.countQuery('SELECT Count() FROM Dashboard USING SCOPE allPrivate where createdby.isactive = false'); 
        } catch (Exception ex) {
            System.debug('DM.GPDIUC exception: '+ex);
            throw new AuraHandledException(ex.getMessage());
        }    
        return iRetVal;
    }
   ////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled(cacheable=true)
    public static List<PrivateDashboardWrapper> getInactiveUsersAndDashboardWrappersWithParams(String pSortField, String pSortOrder){
        List<PrivateDashboardWrapper> lstRetVal = new List<PrivateDashboardWrapper>();
        boolean pGetInactiveOnly = false;
        String strSortOrderCleansed = SanitizeString(pSortOrder);
        String strSortField = convertColumnNameToDbName(pSortField);
        for (Dashboard myDB: getPrivateDashboardsInactiveUsers(strSortField, strSortOrderCleansed)){
            lstRetVal.add(new PrivateDashboardWrapper(myDB.Id, myDB.Title, String.valueof(myDB.lastModifiedDate), myDB.createdbyid, 
                myDB.createdby.FirstName,  myDB.createdby.LastName, myDB.createdby.profile.name, 
                String.valueOf(myDB.createdby.LastLoginDate)));
        }
        return lstRetVal;
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    @testVisible
    private static List<Dashboard> getPrivateDashboardsInactiveUsers(String pSortField, String pSortOrder){
        List<Dashboard> lstDB;
        if (pSortOrder==null){
            pSortOrder = 'asc';
        }
        try {
            String strQuery = 'SELECT Id, Title, lastmodifieddate, CreatedById, CreatedBy.FirstName, CreatedBy.LastName, CreatedBy.Profile.name, CreatedBy.LastLoginDate FROM Dashboard USING SCOPE allPrivate where createdby.isactive = false order by '+pSortField+' '+pSortOrder+' limit 20';
            lstDB = Database.query(strQuery);
        } catch (Exception ex) {
            System.debug('DM.GPDIU exception: '+ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return lstDB;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   @testVisible
   private static String convertColumnNameToDbName(String pColumnName){
        //default it up front
        String strRetVal = 'CreatedBy.LastName';
        if (pColumnName == 'Title'){
            strRetVal = 'Title';
        }else if (pColumnName == 'CreatedByName'){
            strRetVal = 'CreatedBy.LastName';
        }else if (pColumnName == 'DashboardLastModified'){
            strRetVal = 'lastmodifieddate';
        }else if (pColumnName == 'ProfileName'){
            strRetVal = 'CreatedBy.Profile.name';
        }else if (pColumnName == 'LastLogin'){
            strRetVal = 'CreatedBy.LastLoginDate';
        }
        return strRetVal;
   }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //wrapper class
   public class PrivateDashboardWrapper{
    @AuraEnabled public String Title; 
    @AuraEnabled public String DashboardLastModified; 
    @AuraEnabled public String CreatedByName;
    @AuraEnabled public String LinkUser;
    @AuraEnabled public String ProfileName;
    @AuraEnabled public String LastLogin;
    //even though we're not going to show the dashboardid, we need to pass it for delete purposes
    @AuraEnabled public String DashboardId;
        Public PrivateDashboardWrapper (String pDashId, String pTitle, String pDashLastMod, String pCreatedById, String pCreatedByFirstName, String pCreatedByLastName, String pProfileName, String pLastLogin){
            this.DashboardId = pDashId;
            this.Title = pTitle;
            this.DashboardLastModified = pDashLastMod;
            this.CreatedByName = pCreatedByLastName + ', ' + pCreatedByFirstName;
            this.LinkUser =  URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pCreatedById;
            this.ProfileName = pProfileName;
            this.LastLogin = pLastLogin;
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private static string SanitizeString(String pString){
        String strRetVal = string.escapeSingleQuotes(pString);
        return strRetVal.replaceAll('[^\\w]','');
    }
}