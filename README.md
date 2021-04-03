## Why MetdataMaid
As you probably know, Salesforce has a Mass Delete Records -> Mass Delete Reports function that is somewhat useful, but some deletes can be blocked from deletion if they’re included in a Dashboard.  You may find or suspect that inactive users have private dashboards that are blocking your report deletes.  In order to delete those you have to find the inactive users that have private Dashboards and for each one perform the following:
    
    1. Launch the user record
    2. Activate the user
    3. Login as the user
    4. Delete their Dashboards one at time
    5. Logout as that user
    6. Inactivate that user
    7. Feel guilty as your name and the date have been recorded as last modified, and you hope that Security doesn't ask you about it some time in the future.
 

<a href="https://www.simplysfdc.com/2019/03/salesforce-finding-reports-and.html">Great writeup on deleting reports</a> 
 
This tool "should" list all private Dashboards owned by inactive Users and "should" allow you to select and delete the records of your choosing.

## Required Settings
1. You must use My Domain as LWC is utilized in this solution.
2. You must have Enhanced Folder Sharing enabled as we're querying with 'USING SCOPE allPrivate'. (see the next section)

## Enhanced Folder Sharing
There's apparently a lot to consider here if you don't have it currently enabled:

<li><a href="https://www.simplysfdc.com/2014/09/salesforce-enhanced-folder-sharing-for.html">SimplySfdc's Writeup</a></li>
<li><a href="https://help.salesforce.com/apex/HTViewSolution?id=000193465&amp;language=en_US">SF's Considerations and Requirements</a></li>
<li><a href="https://help.salesforce.com/HTViewHelpDoc?id=analytics_sharing_enable.htm">SF's Enhanced Sharing for Reports and Dashboards</a></li>

Finally, if you decide to enable it:

<a href="https://help.salesforce.com/articleView?id=000321245">Instructions for Enabling</a>

## User's Guide

**Data Scope**

Only inactive user's private Dashboards are listed.  I'm only offering 20 records at a time for various reasons.  You should be able to get through the whole list in much less time than it took you to load and configure the app.

**Column Sorting**

Many columns are sortable.  Sorting is performed on the database.  I decided not to offer filtering as I hope you have a limited data set.

**Links**

User Name is a link.  Launching it might tell you more about the user such as inactivated date.  Adding a link for the private Dashboard wouldn't be launchable as you are currently a System Administrator and would have to activate and login as a user to see it.

**Recycle Bin**

Deleted Dashboards can be recovered from the Recycle Bin within 15 days of deletion.

## Code Design
This solution contains a Lighting Web Component (LWC) which require your Org to have My Domain in order to run.

Deletions of Dashboards are done via the REST API.  These are performed one at a time.  Governor limits limit us to 100 callouts per execution.  This is one of the reasons I limited the GUI to 20 records.

**Code Test Classes**

Note that we can not insert a Report or a Dashboard and thus it is very difficult to perform assertions.  The test classes are only here to provide code coverage.

## Installation From Github to Salesforce via Workbench
1. Download the zip from from Github using the green Code button/dropdown.
2. Unzip the file.
3. Navigate INTO the force-app/main/default folder and zip/compress the CONTENTS.  The outcome on a mac should be something like Archive.zip, NOT default.zip.
4. Launch Workbench (float over your name link on the upper right to ensure you're in the correct org), and go to Migration->Deploy
5. Choose the zip of the default folder contents we just created, rollback on error, single package, and if you're going to Production select RunLocalTests.
6. If this fails, go to your org and inspect Setup->Deployment Status

## Post Deployment Steps

1. Go to edit your profile and set:
   - Metadata Maid (Assigned Apps/Custom App Setting) to Visible
   - Private Dashboard Maid (Object Settings/Custom Tab Setting) to Default On
   - Manage All Private Reports and Dashboards to true (This is under System Permissions and may be disabled if you are on a Standard Profile)
2. All classes and pages security should default to System Administrator.  If this is not your profile, you'll need to add your profile to those as well.  You can get a list of the classes and pages from the package.xml which is in the unzipped package you brought down from Github.
3. 

## Future Dreams
Right now I'm only offering you the Private Dashboard Maid, but yes, I hope to add more tabs to the Application.  
Unfortunately, private Reports cannot be deleted or moved without logging in as the user.  I did not find an easy way to programatically login as a user and thus I do not intend to provide the ability to delete private Reports.

```apex
```
