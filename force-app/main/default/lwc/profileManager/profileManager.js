import { LightningElement, wire, track } from 'lwc';
import getProfilesWithUserCounts from '@salesforce/apex/ProfileManager.getProfilesWithUserCounts';
import deleteProfileById from '@salesforce/apex/ProfileManager.deleteProfileById';
import getUsersByProfileIds from '@salesforce/apex/SelectUsersManager.getUsersByProfileIds';
import transferUsersToProfile from '@salesforce/apex/SelectUsersManager.transferUsersToProfile';
//import {refreshApex} from '@salesforce/apex';

//got this from unofficialSF
import { getConfirmation, handleConfirmationButtonClick } from 'c/lwcModalUtil';

export default class ProfileManager extends LightningElement {

    @track profileColumns = [
        { label: 'Profile Link', initialWidth: 300, fieldName: 'ProfileLink', type: 'url',  
            typeAttributes: { label: { fieldName: "ProfileName" }, }, 
            cellAttributes: {
                iconName:{fieldName:'iconNameProfile'},
            },
            sortable: true },
        { label: 'Created Date', fieldName: 'CreatedDate', initialWidth: 150, sortable: "true"},
        { label: 'Created By', initialWidth: 180, fieldName: 'CreatedByLink', type: 'url',  typeAttributes: { label: { fieldName: "CreatedBy" }, tooltip:"User Name", target: "_blank" }, sortable: true },
        { label: 'Custom', fieldName: 'IsCustom', initialWidth: 100, sortable: "true"},
        { label: 'Active #', fieldName: 'NumberOfActiveUsers', initialWidth: 100, sortable: "true" },
        { label: 'Inactive #', fieldName: 'NumberOfInactiveUsers', initialWidth: 110, sortable: "true" },
        { label: 'User Type', fieldName: 'UserType', initialWidth: 120, sortable: "true"},
        { label: 'User License', fieldName: 'UserLicense', initialWidth: 200, sortable: "true"},
     ];

     @track userColumns = [
        { label: 'User Name', initialWidth: 300, fieldName: 'UserLink', type: 'url',  
            typeAttributes: { label: { fieldName: "UserName" } }, 
            cellAttributes: {
                iconName:{fieldName:'iconNameUser'},
            },
            sortable: true },
        { label: 'Email', fieldName: 'Email', initialWidth: 200, sortable: "true"},
        { label: 'Profile Name', initialWidth: 240, fieldName: 'ProfileLink', type: 'url',  typeAttributes: { label: { fieldName: "ProfileName" }, tooltip:"Profile Name", target: "_blank" }, sortable: false },
        { label: 'Company Name', fieldName: 'CompanyName', initialWidth: 150, sortable: "true"},
        { label: 'Created Date', fieldName: 'CreatedDate', initialWidth: 150, sortable: "true"},
        { label: 'Created By', initialWidth: 180, fieldName: 'CreatedByLink', type: 'url',  typeAttributes: { label: { fieldName: "CreatedBy" }, tooltip:"User Name", target: "_blank" }, sortable: true },
        { label: 'Active', fieldName: 'Active', initialWidth: 100, sortable: "true" },
    ];

    @track error;

     userList;
     sortProfileBy = 'ProfileName';
     sortProfileOrder = 'asc';
     sortByFieldUser = 'CreatedDate';
     sortDirectionUser = 'asc';
     retrievedRecordsCount = 0;
     totalRecordsCount = 0;
     selectedUserRows;
     selectedProfileId;
     selectedProfileName;
     selectedToProfileId;
     selectedToProfileName;
     mode = 'Select Action';
     //unofficialSF
     confirmation;
    
     // non-reactive variables
     selectedRows;
     selectedRecord;
     baseProfileList = [];
     toProfileList = [];
     recordCountMessage;
     showTransferBackBtn = false;
     showCancelBtn = false;
     isTransferFrom = false;
     isTransferTo = false;
     isSelectUsers = false;
     isTransferComplete = false;
     isUserOps = false;
     isDeleteMode = false;
     useBaseProfileList = true;
     isLoading = false;

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////// GETTERS AND SORTING /////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    getProfilesByMode(){
        this.isLoading = true;
        getProfilesWithUserCounts({pMode: this.mode, pSortField: this.sortProfileBy, pSortOrder: this.sortProfileOrder})
            .then(data => {
                this.isLoading = false;
                this.retrievedRecordsCount = data.length;
                if (this.isTransferFrom){
                    this.baseProfileList = data;   
                }else if (this.isTransferTo){
                    this.toProfileList = [];
                    //don't display the From Profile in the To list
                    //Gosh, I could have done the following here as well: data.forEach(obj)=> {
                    // data.forEach((obj) => {
                    //     obj.iconName = 'utility:warning';
                    //     obj.cssClass = 'slds-theme_share';
                    //     obj.iconText = 'Salesforce best practice is not to assign users to non custom Profiles';
                    // });

                    for (let i=0; i<data.length;i++){
                        if (this.selectedProfileId != data[i].ProfileId){
                            if (!data[i].IsCustom){
                                data[i].iconNameProfile = 'utility:warning';
                            }
                            //this.toProfileList.push(data[i]);
                            //note that Push isn't working as nothing shows back to the gui????? 
                            //and thus the list won't display, thus the following
                            //https://salesforce.stackexchange.com/questions/252996/array-push-wont-update-lightning-web-component-view
                            this.toProfileList = [...this.toProfileList, data[i]];
                        }
                    }
                }else if (this.mode==='Delete'){
                    this.baseProfileList = data;    
                }
                //go set any pre-selected rows
                this.setSelectedRows(data);
            })
            .catch(error => {
                console.log('GPWUC error: '+error.body.message);
                this.isLoading = false;
                this.error = error.body.message;
              });
    }

    getUsers(){
        this.isLoading = true;
        console.log('GetUsers');
        getUsersByProfileIds({pProfileId: this.selectedProfileId, pSortField: this.sortByFieldUser, pSortOrder: this.sortDirectionUser})
        .then(data => {
            console.log('user count: '+data.length);
            this.userList = data;
            this.isLoading = false;
            for (let i=0; i<data.length;i++){
                if (!data[i].IsCustom){
                    data[i].iconNameUser = 'utility:warning';
                }
            }
        })
        .catch(error => {
            console.log('GU error: '+error.body.message);
            this.error = error.body.message;;
            this.isLoading = false;
        });
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////// DML /////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    deleteProfile(){
        //yeup, that's right, you can only do them one at a time
        deleteProfileById({pProfileId: this.selectedProfileId})
        .then((result) => {
            this.selectedProfileId = null;
            this.selectedProfileName = null;
            this.displayMessage = 'Please select profile to be deleted';
            this.getProfilesByMode();
        })
        .catch((error) => {
            this.error = error.body.message;
        });
   }

   saveTransferUsersClick(){
        //send the From Profile Id, To Profile Id, and User Id List to the controller.method
        if (this.selectedUserRows == null || this.selectedUserRows.length==0){ 
            //pop an error
            alert('Please select User(s) to transfer');
        }else{
            transferUsersToProfile({pToProfileId : this.selectedToProfileId, pUserIds : this.selectedUserRows})
            .then((result) => {
                this.isSelectUsers = false;
                this.isTransferComplete = true;
                this.isUserOps = true;
                this.showTransferBackBtn = false;
                this.isUserOps = false;
                this.showCancelBtn = false;
                //this.getUsers();
            })
            .catch((error) => {
                console.log('STUC error: '+error.body.message);
                this.error = error.body.message;
            });
        }
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////// USER ACTION HANDLERS /////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    processSelectedBaseProfileRecord(event) {
        //this is an array assigned to an array
        this.selectedRows = event.detail.selectedRows;
        this.selectedProfileId = this.selectedRows[0].ProfileId;
        this.selectedProfileName = this.selectedRows[0].ProfileName;       
    }
     
    processSelectedToProfileRecord(event) {
        //this is an array assigned to an array
        this.selectedRows = event.detail.selectedRows;
        this.selectedToProfileId = this.selectedRows[0].ProfileId;
        this.selectedToProfileName = this.selectedRows[0].ProfileName;        
    }

    processSelectedToUserRecord(event) {
        const selectedUserRows = event.detail.selectedRows;
        let userIds = new Set();
        for (let i = 0; i < selectedUserRows.length; i++) {
            userIds.add(selectedUserRows[i].UserId);
        }
        this.selectedUserRows = Array.from(userIds);

    }
    //this is the picklist where the user selects what mode is desired
    selectionChangeHandler(event) {
        this.selectedRows = [];
        this.selectedProfileId = null;
        this.selectedProfileName = null;
        this.mode = event.target.value;
        if (this.mode=='Delete'){
            //this.showDeleteBtn = true;
            this.isDeleteMode = true;
            //this.showSelectToProfileBtn = false;
            this.isTransferFrom = false;
            this.isTransferTo = false;
            this.isSelectUsers = false;
            this.isUserOps = false;
            this.useBaseProfileList = true;
            this.showTransferBackBtn = false;
            this.showCancelBtn = true;
            this.getProfilesByMode();
        }else if (this.mode=='Transfer'){
            //this.showDeleteBtn = false;
            this.isDeleteMode = false;
            //this.showSelectToProfileBtn = true;
            this.isTransferFrom = true;
            this.isTransferTo = false;
            this.isSelectUsers = false;
            this.isUserOps = false;
            this.useBaseProfileList = true;
            this.showCancelBtn = true;
            this.getProfilesByMode();
        }else{
            //the user went back to Select Action
           this.resetPage();
        }
       
	}

    resetPage(){
        this.isDeleteMode = false;
        //this.showSelectToProfileBtn = false;
        this.isTransferFrom = false;
        this.isTransferTo = false;
        this.isSelectUsers = false;
        this.isUserOps = false;
        this.useBaseProfileList = false;
        this.showTransferBackBtn = false;
        
        this.selectedUserRows = null;
        this.selectedProfileId = null;
        this.selectedProfileName = null;
        this.selectedToProfileId = null;
        this.selectedToProfileName = null;
        this.selectedRows = null;
        this.selectedRecord = null;
        this.showCancelBtn = false;
        this.mode = 'Select Action';

        const modeSelector = this.template.querySelector('[name="selectModeName"]');

        modeSelector.selectedIndex = 0;
        //great, I think this is supposed to work.  But, it isn't ?!?!?!?!?!
        
        // this.template.querySelector('[id="selectMode"]').selectedIndex = 0;
        // this.template.querySelector('[name="selectModeName"]').selectedIndex = 0;
    }

    //note that this link offers JS sorting, but it's not reliable for sorting the Profile Link column, so I went with backend sorting
    //http://amitsalesforce.blogspot.com/2020/07/lightning-datatable-sorting-in-lightning-web-components.html
    doBaseProfileSorting(event) {
        this.error = null;
        this.sortProfileBy = event.detail.fieldName;
        this.sortProfileOrder = event.detail.sortDirection;
        //this.baseProfileList = [];
        this.getProfilesByMode();
    }

    doToProfileSorting(event) {
        this.error = null;
        this.sortProfileBy = event.detail.fieldName;
        this.sortProfileOrder = event.detail.sortDirection;
        this.getProfilesByMode()
    }

    doUserSorting(event) {
        //Note that users will be sorted on the database side for a couple reseasons
        //1. the user data is strait from the table with no outside tables or complexities
        //2. there might be thousands of them, and thus there will be a limit on the soql
        this.error = null;
        this.sortByFieldUser = event.detail.fieldName;
        this.sortDirectionUser = event.detail.sortDirection;
        console.log('DUS');
        this.getUsers();
        //this.sortData(this.sortBy, this.sortDirection);
    }

    //from unofficialSF        
    handleDeleteClick(event) {
        if (this.selectedProfileId == null){ 
            //pop an error
            alert('Please select a Profile to delete');
        }else{

            this.displayMessage = 'Are you sure you want to delete the following profile: ';
            this.displayMessage = this.displayMessage + this.selectedProfileName;
            this.deleteConfirmationDetails['text'] = this.displayMessage;
            this.confirmation = getConfirmation(
            this.deleteConfirmationDetails,
            () => this.deleteProfile(), 
            // optional: () => this.handleCancel()
            );
        }
    }

    //from unofficialSF        
    handleSelectToProfileClick(event) {
        //so, I probably want to only allow one at a time
        //alert('It\'s not plugged in yet.  Profile name: '+this.selectedProfileName);
        //we know our this.mode
        //when they click this button, we want to show another page, but this one has all the recods
        if (this.selectedProfileId == null){ 
              //pop an error
              alert('Please select a Profile to Transfer From');
          }else{
              this.mode = 'TransferTo';
              this.showTransferBackBtn = true;
              this.isTransferFrom = false;
              this.isTransferTo = true;
              this.isSelectUsers = false;
              this.isUserOps = false;
              this.useBaseProfileList = false;
              this.getProfilesByMode();
          }
      }
  
      //from unofficialSF        
      handleSelectUsersClick(event) {
          //so, I probably want to only allow one at a time
          //alert('It\'s not plugged in yet.  Profile name: '+this.selectedProfileName);
          //we know our this.mode
          //when they click this button, we want to show another page, but this one has all the recods 
          if (this.selectedProfileId == null){ 
                //pop an error
                alert('Please select a Profile to Transfer To');
            }else{
                //this.mode = 'TransferTo';
                this.showTransferBackBtn = true;
                this.isTransferFrom = false;
                this.isTransferTo = false;
                this.isSelectUsers = true;
                this.isUserOps = true;
                this.useBaseProfileList = false;
                this.getUsers();
                
            }
        }

        handleTransferBackClick(event) {
            //so, I probably want to only allow one at a time
            //we know our this.mode
            //when they click this button, we want to show another page, but this one has all the recods
            if (this.isSelectUsers){
                //this is moving back from users to TO profiles
                this.mode = 'TransferTo';
                this.showTransferBackBtn = true;
                this.isTransferFrom = false;
                this.isTransferTo = true;
                this.isSelectUsers = false;
                this.isUserOps = false;
                //I'm not going to allow them to persist them
                this.selectedUserRows = [];
                //this.toProfileList = [];
            }else if (this.isTransferTo){
                //this is moving back from To profiles to From Profiles
                this.mode = 'Transfer';
                this.showTransferBackBtn = false;
                this.isTransferFrom = true;
                this.isTransferTo = false;
                this.isSelectUsers = false;
                this.isUserOps = false;
                this.useBaseProfileList = true;
            }
            this.error = null;
            this.getProfilesByMode();
        }

        handleTrasferCompleted(){
            //called from the Done button
            this.mode = 'Transfer';
            this.showTransferBackBtn = false;
            this.isTransferFrom = true;
            this.isTransferTo = false;
            this.isSelectUsers = false;
            this.isUserOps = false;
            this.useBaseProfileList = true;
            this.isTransferComplete = false;
            this.selectedProfileId = null;
            this.selectedProfileName = null;
            this.selectedToProfileId = null;
            this.selectedToProfileName = null;

            this.getProfilesByMode();
        }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////// CONFIRMATION /////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //from unofficialSF
    //https://unofficialsf.com/easily-add-confirmation-dialogs-to-your-lightning-components-with-lwcmodal/
    deleteConfirmationDetails = {
        text: this.displayMessage,
        confirmButtonLabel: 'Delete',
        confirmButtonVariant: 'destructive',
        cancelButtonLabel: 'Cancel',
        header: 'Deleted Profiles do NOT go to the Recycle Bin'
    };

    //from unofficialSF
    handleModalButtonClick(event) {
        handleConfirmationButtonClick(event, this.confirmation);
    }
    

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////// BUSINESS/WORKER PROCESSES /////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //I was finding that selected rows was not persisting when moving forward and back between From and To profile lists, so I decided to go the hard way 
    setSelectedRows(data){
        //OK, I can see that when I click on a button, my selectedRows gets set, but after sorting the 2nd time, it becomes
        //undefined.  Interesting.  but, for some reason everything still works, I still get my selected row
       
        if(this.isTransferFrom && this.selectedProfileId){ 
            let my_ids = [];
            for (let i = 0; i < data.length; i++) {
                if (this.selectedProfileId === data[i].ProfileId){
                    my_ids.push(this.selectedProfileId);
                    break;
                }
            }
            this.selectedRows = my_ids;
        }else if(this.isTransferTo && this.selectedToProfileId){
            let my_ids = [];
            for (let i = 0; i < data.length; i++) {
                if (this.selectedToProfileId === data[i].ProfileId){
                    my_ids.push(this.selectedToProfileId);
                    break;
                }
            }
            this.selectedRows = my_ids;
        }
    }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////// TODO /////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //todo, fix these issues
    //1. record counts?
    //2. pagination?
    //3. right now I'm putting a validation on the buttons, making them select records.  I might want to just disable the button similar to what I did on the Delete List views page...maybe????
    // for instance, if you don't select any, I pop an alert.  Good enough for now
}