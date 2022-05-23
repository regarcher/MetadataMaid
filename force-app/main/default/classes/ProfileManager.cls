public with sharing class ProfileManager {
    @AuraEnabled
    public static List<ProfileUserWrapper> getProfilesWithUserCounts(String pMode, String pSortField, String pSortOrder){
        //Note that none of the passed parameters are used in Soql statements
        //this method is used by both the transfer and delete modes with the filtering happening late in the process
        System.debug('PM.GPWUC pMode: '+pMode + 'pSortField: '+ pSortField+' pSortOrder: '+pSortOrder);
        List<ProfileUserWrapper> lstRetVal = new List<ProfileUserWrapper>();
        try{
            Map<id, Profile> mapProfileIdToProfile = new  Map<id, Profile>();
            Map<string, string> mapProfileIdToActiveUserCount = new  Map<string, string>();
            Map<string, string> mapProfileIdToInactiveUserCount = new  Map<string, string>();
            Map<id, boolean> mapProfileIdToIsCustom = new Map<id, boolean>();
            
            //decided against this in favor of the IsOwnedByProfile soql query approach below
            //DateTime dtCreateddatePlusOneHour;
            //We only want to allow the user to delete those profiles that were created by the Org's users, not as part of Salesforce's Org setup
            // if (pMode == 'Delete'){
            //     Organization myO = [SELECT CreatedDate FROM Organization];
            //     dtCreateddatePlusOneHour = myO.Createddate.addHours(1);
            // }
            
            if (!'Delete'.equals(pMode) && !'Transfer'.equals(pMode) && !'TransferTo'.equals(pMode)){
                return lstRetVal;
            }
            mapProfileIdToProfile.putAll([SELECT CreatedById, CreatedBy.name ,CreatedDate,Id, Name, UserLicenseId, UserLicense.name,UserType FROM Profile order by name]);
            
            for (PermissionSet myPS: [SELECT Id, Profileid, IsCustom FROM PermissionSet WHERE IsOwnedByProfile = true]){
                mapProfileIdToIsCustom.put(myPS.ProfileId, myPS.IsCustom);
            }

            System.debug('mapProfileIdToIsCustom.size(): '+mapProfileIdToIsCustom.size());
            
            List<AggregateResult> lstActiveAggRes = [select count(id) cnt, profileid from user where isActive = true group by profileid];
            for (AggregateResult myAR:lstActiveAggRes){
                if (myAR.get('profileid')!=null && myAR.get('cnt') !=null){
                    mapProfileIdToActiveUserCount.put(String.valueOf(myAR.get('profileid')),String.valueOf(myAR.get('cnt')));
                }
            }
            
            //OK, so I found that the approach above for finding Custom Profiles is suspect (IsOwnedByProfile soql filter)
            //For instance, Read Only profile does come with your org, but, it does not show up in that list....so, I'm going
            //to also add all profiles created within one hour of the Org creation to this list.  Note that all the other ones
            //start off with Custom, so I'm going to treat them as custom
            for (Profile myP:mapProfileIdToProfile.values()){
                if (myP.name == 'Read Only'){
                    mapProfileIdToIsCustom.put(myP.id, false);
                }
            }
          
            List<AggregateResult> lstInactiveAggRes = [select count(id) cnt, profileid from user where isActive = false group by profileid];
            for (AggregateResult myAR:lstInactiveAggRes){
                if(myAR.get('profileid')!=null && myAR.get('cnt')!=null){
                    mapProfileIdToInactiveUserCount.put(String.valueOf(myAR.get('profileid')),String.valueOf(myAR.get('cnt')));
                }
            }

            for (id myProId:mapProfileIdToProfile.keyset()){
                //Basically, if we are in delete mode, we don't want to show Standard profiles, only customs added by users of this company
                //and only those profiles that have 0 users (either active or inactive).
                //Also note that it seems logical to me that we would want to only allow transfers if you DO have user counts (either active or inactive)
                Profile myP = mapProfileIdToProfile.get(myProId);
                if (pMode=='Transfer' && (mapProfileIdToActiveUserCount.get(myP.id)!=null || mapProfileIdToInactiveUserCount.get(myP.id)!=null)){
                    lstRetVal.add(new ProfileUserWrapper(myP, mapProfileIdToIsCustom.get(myP.id), mapProfileIdToActiveUserCount.get(myP.id), mapProfileIdToInactiveUserCount.get(myProId), pSortField, pSortOrder));
                }else if (pMode=='Delete' && mapProfileIdToIsCustom.get(myP.id) && mapProfileIdToActiveUserCount.get(myP.id)==null && mapProfileIdToInactiveUserCount.get(myP.id)==null && mapProfileIdToIsCustom.get(myP.id)){
                    lstRetVal.add(new ProfileUserWrapper(myP, mapProfileIdToIsCustom.get(myP.id), mapProfileIdToActiveUserCount.get(myP.id), mapProfileIdToInactiveUserCount.get(myP.id), pSortField, pSortOrder)); 
                }else if (pMode=='TransferTo'){
                    //All profiles are included here
                    //Note however that users should NOT be tranferring to to standard profiles!!!!!
                    lstRetVal.add(new ProfileUserWrapper(myP, mapProfileIdToIsCustom.get(myP.id), mapProfileIdToActiveUserCount.get(myP.id), mapProfileIdToInactiveUserCount.get(myProId), pSortField, pSortOrder));
                }
            }
        }catch(Exception ex){
            System.debug(' ex: '+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        System.debug('PM.GPWUC lstRetVal.size(): '+lstRetVal.size());
        lstRetVal.sort();
        return lstRetVal;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static void deleteProfileById(String pProfileId){
        SfdcRest.deleteProfile(pProfileId);
    }
}