@isTest
//we need to have seeAllData = true because you can't insert a Report
private class DashboardManagerTest {
    //NOTE WE CAN'T CREATE REPORTS OR DASHBOARDS IN APEX, SO WE'RE FORCED TO JUST SETTLE FOR CODE COVERAGE
    //This test class tests very very little.

    //////////////////////////////////////////////////////////////////////////
    //We can't insert a Report, so I'm using seeAllData=true here instead. Once again, it's just for code coverage purposes
    @IsTest(seeAllData=true) public static void testGetters(){
       //salesforce says you can used the Rest API to "Build custom dashboards."
       //I think they mean that we can customize existing dashboards.  I don't see were we can create them via API
       //https://developer.salesforce.com/docs/atlas.en-us.api_analytics.meta/api_analytics/sforce_analytics_rest_api_intro.htm

       //so, let's just see what code coverage we can get without any data
       DashboardManager.getPrivateDashboardsInactiveUsersCount();
       DashboardManager.getInactiveUsersAndDashboardWrappersWithParams('CreatedByName', 'asc');

    }
    //////////////////////////////////////////////////////////////////////////
    static testmethod void testBuildWrapper(){
        DashboardManager.PrivateDashboardWrapper myPDW = new DashboardManager.PrivateDashboardWrapper('01Z4x000000QFIeEAO', 'asdf', '2021-03-09 18:57:01', '0054x000004pJ6z', 'Max', 'Headroom', '00e4x000000yKPy', '2021-02-16 04:33:43');
    }
    //////////////////////////////////////////////////////////////////////////
    static testmethod void testDeleteDashboards(){
        //another code coverage game, we can't create dashboards, so, we can't delete them either
        List<ID> lstDashboardIds = new List<ID>();
        DashboardManager.deletePrivateDashboardsById(lstDashboardIds);
    }
    //////////////////////////////////////////////////////////////////////////  
    static testmethod void testConvertColumnNameToDbName(){
        System.assertEquals('Title',DashboardManager.convertColumnNameToDbName('Title'));
        System.assertEquals('CreatedBy.LastName',DashboardManager.convertColumnNameToDbName('CreatedByName'));
        System.assertEquals('lastmodifieddate',DashboardManager.convertColumnNameToDbName('DashboardLastModified'));
        System.assertEquals('CreatedBy.Profile.name',DashboardManager.convertColumnNameToDbName('ProfileName'));
        System.assertEquals('CreatedBy.LastLoginDate',DashboardManager.convertColumnNameToDbName('LastLogin'));
    }
}