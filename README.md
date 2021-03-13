## How MetdataMaid Helps You
As you probably know, Salesforce has a Mass Delete Records -> Mass Delete Reports function that is somewhat useful, but some deletes can be blocked from deletion if they’re included in a dashboard.  The next step you might take from there is to find Dashboards that haven’t been run in a very long time.  See the section below discussing Deleting Active Dashboards for more tips on that.  Once you’ve cleaned those up you may see that inactive users have private dashboards.  In order to delete those, you have to:
    
    1. Search the user
    2. Activate the user
    3. Login as the user
    4. Delete their dashboards one at time
    5. Logout as that user
    6. Inactivate that user
    7. Feel guilty as your name and the date have been recorded as last modified, and you hope that Security doesn't ask you about it some time in the future.

And repeat that over and over until you’ve deleted them all.
 
This tool will list all private Dashboards owned by inactive users and delete them at your command.

## User's Guide
**Data Scope**
Only inactive user's private dashboards are listed.  I'm only offering 20 records at a time for various reasons.  You should be able to get through the whole list in under 5 minutes.
**Column Sorting**
Many columns are sortable.  Sorting is performed on the database.  I decided not to offer filtering as I hope you have a limited data set.
**Links**
User Name is a link.  Launching it might tell you more about the user such as inactivated date.  Adding a link for the private dashboard wouldn't be launchable as you are currently a System Administrator and would have to activate and login as a user to see it.
**Recycle Bin**
Deleted dashboards can be recovered from the Recycle Bin within 15 days of deletion.

## Code Design
Deletions of Dashboards are done via the REST API.  These are performed one at a time.  Governor limits limit us to 100 callouts per execution.  This is one of the reasons I limited the GUI to 20 records.

## Code Test Classes
Note that we can not insert a report or a dashboard and thus it is very difficult to perform assertions.  The test classes are only here to provide code coverage.

## Future Dreams
Yes, I hope to add more tabs to the Application.  
Unfortunately I did not find an easy way to login as an inactive user and thus I do not intend to provide the ability to delete private Reports.

```apex
```

## Installation
<a href="https://githubsfdeploy.herokuapp.com?owner=regarcher&repo=MetadataMaid">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
