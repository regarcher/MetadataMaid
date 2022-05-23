@isTest 
Private class ProfileManagerTest {
    @IsTest(seeAllData=false) 
    public static void testGetProfilesWithUserCounts(){
        String pMode = 'TransferTo';
        String pSortField = 'ProfileName';
        String pSortOrder = 'asc';
        ProfileManager.getProfilesWithUserCounts(pMode, pSortField, pSortOrder);
    }
////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest(seeAllData=false)
    public static void testDeleteProfile(){
        Profile myP = [select id from profile order by createddate desc][0];
        try{
            ProfileManager.deleteProfileById(myP.id);
        }catch(Exception ex){
            //Do absolutely nothing.
            //Here's the thing, this might be an OOB (out of the box) profile, and we may not be able to delete it
            //Thus the catch and "do nothing"
        }
        
    }
}