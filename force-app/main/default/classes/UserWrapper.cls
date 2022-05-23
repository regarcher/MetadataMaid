Global with sharing class UserWrapper implements Comparable{
    @AuraEnabled public String UserId; 
    @AuraEnabled public String UserLink; 
    @AuraEnabled public String UserName; 
    @AuraEnabled public String Email; 
    @AuraEnabled public String CompanyName;
    @AuraEnabled public String ProfileLink;
    @AuraEnabled public String ProfileName;
    @AuraEnabled public String CreatedDate;
    @AuraEnabled public String CreatedBy;
    @AuraEnabled public String CreatedByLink;
    @AuraEnabled public Boolean Active;
    @AuraEnabled public Boolean IsCustom;


    Public UserWrapper (User pUser, Boolean pIsCustom){
        this.UserId = pUser.id;
        this.UserLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pUser.Id; 
        this.UserName = pUser.name; 
        this.Email = pUser.email; 
        this.CompanyName = pUser.companyname; 
        this.ProfileLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pUser.profileId; 
        this.ProfileName = pUser.profile.name; 
        this.CreatedDate = String.valueof(pUser.CreatedDate); 
        this.CreatedBy = pUser.createdby.name; 
        this.CreatedByLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pUser.createdbyid; 
        this.Active = pUser.isActive; 
        this.IsCustom = pIsCustom;
        
    }
    //for now we're doing our sorting via soql in the SelctUsersManager class
    global Integer compareTo(Object objToCompare) {
        return 0;
    }
}
