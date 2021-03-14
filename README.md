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
Deletions of Dashboards are done via the REST API.  These are performed one at a time.  Governor limits limit us to 100 callouts per execution.  This is one of the reasons I limited the GUI to 20 records.

## Code Test Classes
Note that we can not insert a Report or a Dashboard and thus it is very difficult to perform assertions.  The test classes are only here to provide code coverage.

## Future Dreams
Right now I'm only offering you the Private Dashboard Maid, but yes, I hope to add more tabs to the Application.  
Unfortunately, private Reports cannot be deleted or moved without logging in as the user.  I did not find an easy way to programatically login as a user and thus I do not intend to provide the ability to delete private Reports.

```apex
```

## Half Baked Installation 
Unfortunately I was only able to get this installer to bring down Classes and Pages.  I could not get it to bring down CustomApplication, CustomTab, LightningComponentBundle, or FlexiPage.
<a href="https://githubsfdeploy.herokuapp.com?owner=regarcher&repo=MetadataMaid&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## Installation Via 

## Post Deployment Steps
So, it seems that the free deployment tool you see above isn't working propery in that it doesn't deploy Applications, Tabs, or LWC .
You have a couple options.
1. You can deploy with the code above and go to the Lightning App Builder and create a Lightning App Page named "Private Dashboard Maid" an application named "Metadata Maid" which includes the tab.  This tab 
2. You can
