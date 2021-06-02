@isTest
    //source: https://github.com/regarcher/MetadataMaid
private class ViewManagerTest {
    static testmethod void testGetViews(){
        Map<String,String> mapStringToString = new Map<String,String>();
        mapStringToString.put('query','Amount > 1000');
        mapStringToString.put('scope','everything');

        HttpMockMaidFactory mock = new HttpMockMaidFactory(200, 'OK', JSON.serialize(mapStringToString), new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);

        ViewManager.getObjectTypePicklistValues();
        ViewManager.getViewsCountByObjectName('Opportuinity');

        Test.startTest();
        ViewManager.getViewsByObjectName('Opportunity', 'LastModifiedDate', 'asc');
        Test.stopTest();

        //bump up code coverage
        ViewManager.convertColumnNameToDbName('CreatedDate');
        ViewManager.convertColumnNameToDbName('Name');
        ViewManager.convertColumnNameToDbName('ProfileName');
        ViewManager.convertColumnNameToDbName('LastModifiedDate');
        ViewManager.fetchUserSessionId();
    }
    //////////////////////////////////////////////////////////////////////////
    static testmethod void testBuildWrapper(){
        ViewManager.PublicViewWrapper myPVW = new ViewManager.PublicViewWrapper ('00B4x00000BbtmLEAR', 'frivolous view', 'frivolous_view', 'Opportunity', '2021-03-09 18:57:01', '2021-03-10 18:57:01', '0054x000003TjxSAAS', 'Joe', 'Dirt', '0054x000003TjxSAAS', 'Joe', 'Dirt', 'everything', 'Amount > 1000');
        //the constructor is pretty simple, I'm not going to assert each and every value
        System.AssertEquals('frivolous_view',myPVW.DeveloperName);
        List<ViewManager.PublicViewWrapper> lstPVW = new List<ViewManager.PublicViewWrapper>();
        lstPVW.add(myPVW);

        //while we're here, let's delete it too...  
        ViewManager.deletePublicViews(JSON.serialize(lstPVW));

    }
   
}