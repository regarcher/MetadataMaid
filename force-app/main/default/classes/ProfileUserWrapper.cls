Global with sharing class ProfileUserWrapper implements Comparable{
    @AuraEnabled public String ProfileId; 
    @AuraEnabled public String ProfileLink; 
    @AuraEnabled public String ProfileName; 
    @AuraEnabled public String CreatedDate;
    @AuraEnabled public String CreatedBy;
    @AuraEnabled public String CreatedByLink;
    @AuraEnabled public Boolean IsCustom;
    @AuraEnabled public String UserType;
    @AuraEnabled public String UserLicense;
    @AuraEnabled public String NumberOfActiveUsers;
    @AuraEnabled public String NumberOfInactiveUsers;
    @AuraEnabled public Boolean CanDelete;

    public String sortBy;
    public String orderBy;

    Public ProfileUserWrapper (Profile pProfile, Boolean pIsCustom, string pActiveUserCount, string pInactiveUserCount, string pSortBy, string pOrderBy){
        this.ProfileId = pProfile.id;
        this.ProfileLink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pProfile.id;
        this.ProfileName = pProfile.name;
        this.CreatedDate = String.valueof(pProfile.Createddate);
        this.CreatedBy = pProfile.CreatedBy.name;
        this.CreatedByLink =  URL.getSalesforceBaseUrl().toExternalForm()+'/'+ pProfile.CreatedById;
        this.IsCustom =  pIsCustom;
        this.UserType =  pProfile.UserType;
        this.UserLicense = pProfile.UserLicense.name;

        this.sortBy = pSortBy;
        this.orderBy = pOrderBy;

        if (pActiveUserCount!=null){
            this.NumberOfActiveUsers = pActiveUserCount;
        }else{
            this.NumberOfActiveUsers ='0';
        }
        if (pInactiveUserCount!=null){
            this.NumberOfInactiveUsers = pInactiveUserCount;
        }else{
            this.NumberOfInactiveUsers = '0';
        }
        if (this.NumberOfActiveUsers!='0' || this.NumberOfInactiveUsers!='0' || !this.IsCustom){
            this.CanDelete = false;
        }else{
            this.CanDelete = true;
        }
        //so, the error I get is "The attempted delete was invalid for your session. Please refresh your page and try again."
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //implements Comparable sorting works better than other solutions for this implementation as 
    //1. some solutions don't sort Links reliably
    //2. I've got active and inactive user counts which are add-ons to this object which can't be sorted in soql
    global Integer compareTo(Object objToCompare) {
        System.debug('compare');
        ProfileUserWrapper compareToWrap = (ProfileUserWrapper)objToCompare;
        if(sortBy == 'ProfileLink'){
            if (orderBy == 'asc'){
                if (ProfileLink == compareToWrap.ProfileName){
                    return 0;
                }else if (ProfileName > compareToWrap.ProfileName){
                    return 1;
                }else{
                    return -1;    
                }
            }else{
                //is descending
                if (ProfileName == compareToWrap.ProfileName){
                    return 0;
                }else if (ProfileName < compareToWrap.ProfileName){
                    return 1;
                }else{
                    return -1;    
                }
            }
        }else if(sortBy == 'CreatedDate'){
            if (orderBy == 'asc'){
                if (CreatedDate == compareToWrap.CreatedDate){
                    return 0;
                }else if (CreatedDate > compareToWrap.CreatedDate){
                    return 1;
                }else{
                    return -1;    
                }
            }else{
                //is descending
                if (CreatedDate == compareToWrap.CreatedDate){
                    return 0;
                }else if (CreatedDate < compareToWrap.CreatedDate){
                    return 1;
                }else{
                    return -1;    
                }
            }
        }else if(sortBy == 'CreatedByLink'){
            if (orderBy == 'asc'){
                if (CreatedByLink == compareToWrap.CreatedByLink){
                    return 0;
                }else if (CreatedByLink > compareToWrap.CreatedByLink){
                    return 1;
                }else{
                    return -1;    
                }
            }else{
                //is descending
                if (CreatedByLink == compareToWrap.CreatedByLink){
                    return 0;
                }else if (CreatedByLink < compareToWrap.CreatedByLink){
                    return 1;
                }else{
                    return -1;    
                }
            }
        }else if(sortBy == 'IsCustom'){
            if (orderBy == 'asc'){
                if (IsCustom == compareToWrap.IsCustom){
                    return 0;
                }else if (IsCustom && !compareToWrap.IsCustom){
                    return 1;
                }else{
                    return -1;    
                }
            }else{
                //is descending
                if (IsCustom == compareToWrap.IsCustom){
                    return 0;
                }else if (!IsCustom && compareToWrap.IsCustom){
                    return 1;
                }else{
                    return -1;    
                }
            }

        }else if(sortBy == 'UserType'){
            if (orderBy == 'asc'){
                if (UserType == compareToWrap.UserType){
                    return 0;
                }else if (UserType > compareToWrap.UserType){
                    return 1;
                }else{
                    return -1;    
                }
            }else{
                //is descending
                if (UserType == compareToWrap.UserType){
                    return 0;
                }else if (UserType < compareToWrap.UserType){
                    return 1;
                }else{
                    return -1;    
                }
            }
        }else if(sortBy == 'UserLicense'){
            if (orderBy == 'asc'){
                if (UserLicense == compareToWrap.UserLicense){
                    return 0;
                }else if (UserLicense > compareToWrap.UserLicense){
                    return 1;
                }else{
                    return -1;    
                }
            }else{
                //is descending
                if (UserLicense == compareToWrap.UserLicense){
                    return 0;
                }else if (UserLicense < compareToWrap.UserLicense){
                    return 1;
                }else{
                    return -1;    
                }
            }
        }else if(sortBy == 'NumberOfActiveUsers'){
            if (orderBy == 'asc'){
                if (NumberOfActiveUsers == compareToWrap.NumberOfActiveUsers){
                    return 0;
                }else if (NumberOfActiveUsers > compareToWrap.NumberOfActiveUsers){
                    return 1;
                }else{
                    return -1;    
                }
            }else{
                //is descending
                if (NumberOfActiveUsers == compareToWrap.NumberOfActiveUsers){
                    return 0;
                }else if (NumberOfActiveUsers < compareToWrap.NumberOfActiveUsers){
                    return 1;
                }else{
                    return -1;    
                }
            }
        }else if(sortBy == 'NumberOfInactiveUsers'){
            if (orderBy == 'asc'){
                if (NumberOfInactiveUsers == compareToWrap.NumberOfInactiveUsers){
                    return 0;
                }else if (NumberOfInactiveUsers > compareToWrap.NumberOfInactiveUsers){
                    return 1;
                }else{
                    return -1;    
                }
            }else{
                //is descending
                if (NumberOfInactiveUsers == compareToWrap.NumberOfInactiveUsers){
                    return 0;
                }else if (NumberOfInactiveUsers < compareToWrap.NumberOfInactiveUsers){
                    return 1;
                }else{
                    return -1;    
                }
            }
        }else{
            return 0;
        }
    }
}
