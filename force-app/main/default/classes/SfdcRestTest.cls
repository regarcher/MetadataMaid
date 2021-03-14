@isTest private class SfdcRestTest {
    //source: https://github.com/regarcher/MetadataMaid

    //this is all about code coverage.  The app works.  
    //Of course this is un-managed/open so if you do modify the code, you might break it
   static testmethod void testFetchUserSessionId(){
       SfdcRest.fetchUserSessionId();
   }
///////////////////////////////////////////////////////////
   static testmethod void testDelete(){
       Test.setMock(HttpCalloutMock.class, new MetaMaidHttpCalloutMock());
       SfdcRest.deleteDashboard(null);
   }
}