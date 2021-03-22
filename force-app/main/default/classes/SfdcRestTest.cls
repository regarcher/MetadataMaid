@isTest private class SfdcRestTest {
    //source: https://github.com/regarcher/MetadataMaid

    //this is all about code coverage.  The app works.  
    //Of course this is un-managed/open so if you do modify the code, you might break it
   static testmethod void testFetchUserSessionId(){
        String strSessionId = SfdcRest.fetchUserSessionId();
        System.assertNotEquals(null, strSessionId);
   }
///////////////////////////////////////////////////////////
   static testmethod void testDelete(){
       Test.setMock(HttpCalloutMock.class, new MetaMaidHttpCalloutMock());
       boolean bSuccess = SfdcRest.deleteDashboard(null);
       System.assertEquals(true, bSuccess);
   }
}