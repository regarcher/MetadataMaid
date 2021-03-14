## Why MetdataMaid
As you probably know, Salesforce has a Mass Delete Records -> Mass Delete Reports function that is somewhat useful, but some deletes can be blocked from deletion if they’re included in a Dashboard.  You may find or suspect that inactive users have private dashboards that are blocking your report deletes.  In order to delete those you have to find the inactive users that have private Dashboards and for each one perform the following:
    1. Launch the user record
    2. Activate the user
    3. Login as the user
    4. Delete their Dashboards one at time
    5. Logout as that user
    6. Inactivate that user
    7. Feel guilty as your name and the date have been recorded as last modified, and you hope that Security doesn't ask you about it some time in the future.
 
This tool will list all private Dashboards owned by inactive Users and allow you to select and delete the records of your choosing.

You must have My Domain turned on to utilize this App.

## User's Guide

**Data Scope**

Only inactive user's private Dashboards are listed.  I'm only offering 20 records at a time for various reasons.  You should be able to get through the whole list in under 5 minutes.

**Column Sorting**

Many columns are sortable.  Sorting is performed on the database.  I decided not to offer filtering as I hope you have a limited data set.

**Links**

User Name is a link.  Launching it might tell you more about the user such as inactivated date.  Adding a link for the private Dashboard wouldn't be launchable as you are currently a System Administrator and would have to activate and login as a user to see it.

**Recycle Bin**

Deleted Dashboards can be recovered from the Recycle Bin within 15 days of deletion.

## Code Design
This solution contains a Lighting Web Component (LWC) which require your Org to have My Domain in order to run.
Deletions of Dashboards are done via the REST API.  These are performed one at a time.  Governor limits limit us to 100 callouts per execution.  This is one of the reasons I limited the GUI to 20 records.

## Code Test Classes
Note that we can not insert a Report or a Dashboard and thus it is very difficult to perform assertions.  The test classes are only here to provide code coverage.

## Future Dreams
Right now I'm only offering you the Private Dashboard Maid, but yes, I hope to add more tabs to the Application.  
Unfortunately, private Reports cannot be deleted or moved without logging in as the user.  I did not find an easy way to programatically login as a user and thus I do not intend to provide the ability to delete private Reports.

```apex
```

## Half Baked Installation (FAIL)
Unfortunately I was only able to get this installer to bring down Classes and Pages.  I could not get it to bring down CustomApplication, CustomTab, LightningComponentBundle, or FlexiPage.  Yes, I tried Andy's recommendation to include a package.xml, but it didn't help me.  If you have any suggestions on how to fix this, please let me know.

<a href="https://githubsfdeploy.herokuapp.com?owner=regarcher&repo=MetadataMaid&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Installation From Github to Salesforce via Workbench
1. Download the zip from from Github using the green Code button/dropdown.
2. Unzip the file.
3. Navigate to the force-app/main/default folder and zip the contents.
4. Launch Workbench (watch your url to verify that you're launching the correct Org), and go to Migration->Deploy
5. Choose the zip of the default folder contents we just created, rollback on error, single package, and if you're going to Production select RunLocalTests.
6. If this fails, go to your org and inspect Setup->Deployment Status

## Post Deployment Steps
1. Go to edit your profile and set the Metadata Maid (Custom App Setting) to Visible and set the Private Dashboard Maid (Custom Tab Setting) to Default On
2.  
