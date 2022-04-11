import { LightningElement, wire, track } from 'lwc';
import getProfilesWithUserCounts from '@salesforce/apex/ProfileManager.getProfilesWithUserCounts';
import deleteProfileById from '@salesforce/apex/ProfileManager.deleteProfileById';
import {refreshApex} from '@salesforce/apex';

//unofficialSF
import { getConfirmation, handleConfirmationButtonClick } from 'c/lwcModalUtil';

export default class ProfileManager extends LightningElement {

    @track columns = [
        { label: 'Profile Name', initialWidth: 270, fieldName: 'ProfileLink', type: 'url',  typeAttributes: { label: { fieldName: "ProfileName" }, tooltip:"Profile Name", target: "_blank" }, sortable: true },
        { label: 'Created Date', fieldName: 'CreatedDate', initialWidth: 150, sortable: "true"},
        { label: 'Created By', initialWidth: 150, fieldName: 'CreatedByLink', type: 'url',  typeAttributes: { label: { fieldName: "CreatedBy" }, tooltip:"User Name", target: "_blank" }, sortable: true },
        { label: 'Custom', fieldName: 'IsCustom', initialWidth: 100, sortable: "true" },
        { label: 'Active Users', fieldName: 'NumberOfActiveUsers', initialWidth: 140, sortable: "true" },
        { label: 'Inactive Users', fieldName: 'NumberOfInactiveUsers', initialWidth: 150, sortable: "true" },
        { label: 'User Type', fieldName: 'UserType', initialWidth: 120, sortable: "true"},
        { label: 'User License', fieldName: 'UserLicense', initialWidth: 220, sortable: "true"},
        { label: 'Action', initialWidth: 50, fieldName: 'deleteLink', type: 'url',  typeAttributes: { label:"delete", target: "_blank" } },
     ];
    
     @track profileList;
     @track sortBy = 'CreatedDate';
     @track sortDirection = 'asc';
     @track retrievedRecordsCount = 0;
     @track totalRecordsCount = 0;
     @track selectedRows = [];
     @track selectedProfileId;
     @track selectedProfileName;
     @track mode = 'Select Action';
     @track error;
      //unofficialSF
    @track confirmation;
    //confirmModal support
     @track displayMessage = 'Please select profile to be deleted';
    
     // non-reactive variables
     selectedRecord;
     recordCountMessage;
     showDeleteBtn = false;
     showTransferBtn = false;
     showTransferBackBtn = false;
     isTransferFrom = false;
     isTransferTo = false;
     refreshCount;
     isLoading = false;
  
     
     @wire(getProfilesWithUserCounts, {pMode: '$mode'})
        wiredProfiles(result) {
            this.refreshCount = result
            this.isLoading = true;
            //reggie, why is this executing when I sort the column?
            this.refreshTable = result;
            if (result.data) {
                this.isLoading = false;
                this.retrievedRecordsCount = result.data.length;
                this.profileList = result.data;
                if (result.data.length===0){
                    this.totalRecordsCount = result.data.length;
                }else if(this.isTransferFrom && this.selectedProfileId){ 
                    let my_ids = [];
                    for (let i = 0; i < result.data.length; i++) {
                        if (this.selectedProfileId && this.selectedProfileId === result.data[i].ProfileId){
                            my_ids.push(this.selectedProfileId);
                        }
                    }
                    this.selectedRows = my_ids;
                }
               
                //this.profileList = result.data;
                this.recordCountMessage = 'Records retrieved: '+this.retrievedRecordsCount+' of '+this.totalRecordsCount;
                console.log(this.recordCountMessage);
            } else if (result.error) {
                this.isLoading = false;
                this.error = error.body.message;
            }
        }
    processSelectedRecord(event) {
        this.selectedRows = event.detail.selectedRows;
        this.selectedProfileId = this.selectedRows[0].ProfileId;
        this.selectedProfileName = this.selectedRows[0].ProfileName;
    }
     
        //this is the picklist where the user selects what mode is desired
     selectionChangeHandler(event) {
        this.selectedRows = null;
        this.selectedProfileId = null;
        this.selectedProfileName = null;
        this.mode = event.target.value;
        if (this.mode=='Delete'){
            this.showDeleteBtn = true;
            this.showTransferBtn = false;
            this.isTransferFrom = false;
            this.isTransferTo = false;
        }else if (this.mode=='Transfer'){
            this.showDeleteBtn = false;
            this.showTransferBtn = true;
            this.isTransferFrom = true;
            this.isTransferTo = false;
        }
	}

//http://amitsalesforce.blogspot.com/2020/07/lightning-datatable-sorting-in-lightning-web-components.html
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        console.log('Sort');
        let parseData = JSON.parse(JSON.stringify(this.profileList));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.profileList = parseData;
    }    

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

    deleteProfile(){
        deleteProfileById({pProfileId: this.selectedProfileId})
        .then((result) => {
            this.selectedProfileId = null;
            this.selectedProfileName = null;
            this.displayMessage = 'Please select profile to be deleted';
            return refreshApex(this.refreshCount);
        })
        .catch((error) => {
            this.error = error.body.message;
        });
   }

    //from unofficialSF        
    handleTransferClick(event) {
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
        }
    }

    handleTransferBackClick(event) {
        //so, I probably want to only allow one at a time
        //we know our this.mode
        //when they click this button, we want to show another page, but this one has all the recods
        this.mode = 'Transfer';
        this.showTransferBackBtn = false;
        this.isTransferFrom = true;
        this.isTransferTo = false;
      }

     //from unofficialSF
     handleModalButtonClick(event) {
        handleConfirmationButtonClick(event, this.confirmation);
    }

}