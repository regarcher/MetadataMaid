public with sharing class ProfileManager {

    @AuraEnabled(cacheable=true)
    public static List<ProfileUserWrapper> getProfilesWithUserCounts(String pMode){
        Map<id, Profile> mapProfileIdToProfile = new  Map<id, Profile>();
        Map<string, string> mapProfileIdToActiveUserCount = new  Map<string, string>();
        Map<string, string> mapProfileIdToInactiveUserCount = new  Map<string, string>();
        Map<id, boolean> mapProfileIdToIsCustom = new Map<id, boolean>();
        DateTime dtCreateddatePlusOneHour;

        List<ProfileUserWrapper> lstRetVal = new List<ProfileUserWrapper>();
        if (!'Delete'.equals(pMode) && !'Transfer'.equals(pMode)){
            return lstRetVal;
        }
        mapProfileIdToProfile.putAll([SELECT CreatedById, CreatedBy.name ,CreatedDate,Id, Name, UserLicenseId, UserLicense.name,UserType FROM Profile order by name]);
        
        for (PermissionSet myPS: [SELECT Id, Profileid, IsCustom FROM PermissionSet WHERE IsOwnedByProfile = true]){
            mapProfileIdToIsCustom.put(myPS.ProfileId, myPS.IsCustom);
        }

        if (pMode == 'Delete'){
            Organization myO = [SELECT CreatedDate FROM Organization];
            dtCreateddatePlusOneHour = myO.Createddate.addHours(1);
        }

        List<AggregateResult> lstActiveAggRes = [select count(id) cnt, profileid from user where isActive = true group by profileid];
        for (AggregateResult myAR:lstActiveAggRes){
            //reggie, need to protect against nulls, somehow
            mapProfileIdToActiveUserCount.put(String.valueOf(myAR.get('profileid')),String.valueOf(myAR.get('cnt')));
        }
        
        List<AggregateResult> lstInactiveAggRes = [select count(id) cnt, profileid from user where isActive = false group by profileid];
        for (AggregateResult myAR:lstInactiveAggRes){
            //reggie, need to protect against nulls, somehow
            mapProfileIdToInactiveUserCount.put(String.valueOf(myAR.get('profileid')),String.valueOf(myAR.get('cnt')));
        }
        
        for (id myProId:mapProfileIdToProfile.keyset()){
            //basically, if we are in delete mode, we don't want to show Standard profiles, only customs
            
            Profile myP = mapProfileIdToProfile.get(myProId);
            if (pMode=='Transfer'){
                lstRetVal.add(new ProfileUserWrapper(myP, mapProfileIdToIsCustom.get(myP.id), mapProfileIdToActiveUserCount.get(myP.id), mapProfileIdToInactiveUserCount.get(myProId)));
            }else if (pMode=='Delete' && mapProfileIdToIsCustom.get(myP.id) && mapProfileIdToActiveUserCount.get(myP.id)==null && mapProfileIdToInactiveUserCount.get(myP.id)==null && myP.createddate > dtCreateddatePlusOneHour){
                lstRetVal.add(new ProfileUserWrapper(myP, mapProfileIdToIsCustom.get(myP.id), mapProfileIdToActiveUserCount.get(myP.id), mapProfileIdToInactiveUserCount.get(myP.id))); 
            }
        }

        return lstRetVal;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static void deleteProfileById(String pProfileId){
        SfdcRest.deleteProfile(pProfileId);
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   //wrapper class
   public class ProfileUserWrapper{
    @AuraEnabled public String ProfileId; 
    @AuraEnabled public String ProfileLink; 
    @AuraEnabled public String ProfileName; 
    @AuraEnabled public String CreatedDate;
    @AuraEnabled public String CreatedBy;
    @AuraEnabled public String CreatedByLink;
    @AuraEnabled public Boolean IsCustom;
    @AuraEnabled public String UserType;
    @AuraEnabled public String UserLicense;
    @AuraEnabled public String NumberOfActiveUsers;
    @AuraEnabled public String NumberOfInactiveUsers;
    @AuraEnabled public Boolean CanDelete;
    @AuraEnabled public String deleteLink;
    
    Public ProfileUserWrapper (Profile pProfile, Boolean pIsCustom, string pActiveUserCount, string pInactiveUserCount){

            this.ProfileId = pProfile.id;
            this.ProfileLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pProfile.id;
            this.ProfileName = pProfile.name;
            this.CreatedDate = String.valueof(pProfile.Createddate);
            this.CreatedBy = pProfile.CreatedBy.name;
            this.CreatedByLink =  URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pProfile.CreatedById;
            this.IsCustom =  pIsCustom;
            this.UserType =  pProfile.UserType;
            this.UserLicense = pProfile.UserLicense.name;
            if (pActiveUserCount!=null){
                this.NumberOfActiveUsers = pActiveUserCount;
            }else{
                this.NumberOfActiveUsers ='0';
            }
            if (pInactiveUserCount!=null){
                this.NumberOfInactiveUsers = pInactiveUserCount;
            }else{
                this.NumberOfInactiveUsers = '0';
            }
            if (this.NumberOfActiveUsers!='0' || this.NumberOfInactiveUsers!='0' || !this.IsCustom){
                this.CanDelete = false;
            }else{
                this.CanDelete = true;
            }
            this.deleteLink = '/setup/own/deleteredirect.jsp?delID='+pProfile.id+'&retURL=%2F00e';
            //so, the error I get is "The attempted delete was invalid for your session. Please refresh your page and try again."
            
        }
    }
}
