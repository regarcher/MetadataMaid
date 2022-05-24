public with sharing class SelectUsersManager {
  //source: https://github.com/regarcher/MetadataMaid
  //This code is part of a package and should not be called from your custom code
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static List<UserWrapper> getUsersByProfileIds(String pProfileId, String pSortField, String pSortOrder){
        //how many should I allow?  Note that Chatter Free User counts might be 5k+
        System.debug('SUM.GUBPI id: '+pProfileId+ ' sort: '+pSortField+' order: '+pSortOrder);
        
        DateTime dtCreateddatePlusOneHour;
        Organization myO = [SELECT CreatedDate FROM Organization];
        dtCreateddatePlusOneHour = myO.Createddate.addHours(1);
        List<UserWrapper> lstRetVal = new List<UserWrapper>();
        try{
            String strSortOrderCleansed = mdmUtilClass.SanitizeString(pSortOrder);
            String strSortField = convertColumnNameToDbName(pSortField);
            String strQuery = 'select id, name, email, CompanyName, profileid, profile.name, createdbyid, createdby.name, isActive, CreatedDate from user where profileid = \''+ pProfileId + '\' order by '+strSortField+' '+strSortOrderCleansed;
            List<User> lstUser = Database.query(strQuery);
            for (User myU:lstUser){
                lstRetVal.add(new UserWrapper(myU, myU.createddate > dtCreateddatePlusOneHour)); 
            }
        }catch(Exception ex){
            System.debug('SUM.GUBPI ex: '+ex.getMessage()+ ' stack: '+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
        return lstRetVal;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static void transferUsersToProfile(String pToProfileId, List<String> pUserIds){
        System.debug('SUM.TUTP pUserIds.size(): '+pUserIds.size()+ ' pToProfileId: '+pToProfileId);
        try {
            if (String.isNotBlank(pToProfileId) && pUserIds != null && pUserIds.size()>0){
                List<User> lstUser = new List<User>();
                for (String strUserId:pUserIds){
                    User myU = new User();
                    myU.id = strUserId;
                    myU.profileid = pToProfileId;
                    lstUser.add(myU);
                    System.debug('SUM.TUTP uId: '+strUserId);
                }
                update lstUser;
            }
        } catch (Exception ex) {
            System.debug('SUM.TUTP ex: '+ex+ ' stack: '+ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   @testVisible
   private static String convertColumnNameToDbName(String pColumnName){
        //default it up front
        String strRetVal = 'Name';
        if (pColumnName == 'User Name'){
            strRetVal = 'name';
        }else if (pColumnName == 'Email'){
            strRetVal = 'Email';
        }else if (pColumnName == 'Company Name'){
            strRetVal = 'companyname';
        }else if (pColumnName == 'Created Date'){
            strRetVal = 'CreatedDate';
        }else if (pColumnName == 'Created By'){
            strRetVal = 'createdby.name';
        }else if (pColumnName == 'Active'){
            strRetVal = 'isActive';
        }
        return strRetVal;
   }
}