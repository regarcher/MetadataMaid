@isTest
private class SelectUsersManagerTest {
    Private Static Id chatterFreeProfileId;
    Private Static ID chatterModeratorProfileId;
    @testSetup static void setUpData() {
        //insert users
        getProfileIds();
        User myU = new User();
        myU.profileId = chatterFreeProfileId;
        myU.FirstName = 'Tony';
        myU.LastName = 'Tiger';
        myU.email = 'tonytiger@gmail.com';

    }
    ////////////////////////////////////////////////////////////////////////////////////////
    @IsTest(seeAllData=false) public static void testGetUsersByProfileIds(){
        getProfileIds();
        String pSortField = 'Name';
        String pSortOrder = 'asc';
        List<String> lstUserIds = new List<String>();
        List<UserWrapper> lstUW = SelectUsersManager.getUsersByProfileIds(chatterFreeProfileId, pSortField, pSortOrder);
        for(UserWrapper myWrap:lstUW){
            lstUserIds.add(myWrap.UserId);
        }
        pSortField = 'Email';
        pSortOrder = 'desc';
        lstUW = SelectUsersManager.getUsersByProfileIds(chatterFreeProfileId, pSortField, pSortOrder);
        SelectUsersManager.transferUsersToProfile(chatterModeratorProfileId, lstUserIds);

    }
    ////////////////////////////////////////////////////////////////////////////////////////
    private static void getProfileIds(){
        for(Profile myP:[select id, name from Profile where name like 'Chatter%']){
            System.debug('SUMT.GPI myP: '+myP);
            if (myP.name=='Chatter Free User'){
                chatterFreeProfileId = myP.id;
            }else if (myP.name=='Chatter Moderator User'){
                chatterModeratorProfileId = myP.id;
            }else{
                System.debug('SUMT.GPI did not match');
            }
        }
    }
}