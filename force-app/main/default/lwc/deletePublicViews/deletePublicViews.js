//deletePublicViews.js
//source: https://github.com/regarcher/MetadataMaid
import { LightningElement, wire, track } from 'lwc';
import getViewsByObjectName from '@salesforce/apex/ViewManager.getViewsByObjectName';
import getViewsCountByObjectName from '@salesforce/apex/ViewManager.getViewsCountByObjectName';
import getObjectTypePicklistValues from '@salesforce/apex/ViewManager.getObjectTypePicklistValues';
import deletePublicViews from '@salesforce/apex/ViewManager.deletePublicViews';
import {refreshApex} from '@salesforce/apex';

//unofficialSF
import { getConfirmation, handleConfirmationButtonClick } from 'c/lwcModalUtil';

export default class DeletePublicViews extends LightningElement {
    //reactive variables
    @track columns = [
        
        //{ label: 'View Name', fieldName: 'Name', type: 'text', sortable: true }
        //I just get insufficient privileges when I attempt to click these links...why?
        { label: 'View Name', initialWidth: 340, fieldName: 'LinkView', type: 'url', typeAttributes: { label: { fieldName: "Name" }, tooltip:"View Name", target: "_blank" }, sortable: true }
        ,{ label: 'Last Modified Date', initialWidth: 160, fieldName: 'LastModifiedDate', type: 'text', sortable: true }
        ,{ label: 'Last Modified By', initialWidth: 160, fieldName: 'ModLinkUser', type: 'url',  typeAttributes: { label: { fieldName: "ModByName" }, tooltip:"User Name", target: "_blank" }, sortable: true }
        ,{ label: 'Created Date', initialWidth: 160, fieldName: 'CreatedDate', type: 'text', sortable: true }
        ,{ label: 'Created By', initialWidth: 160, fieldName: 'LinkUser', type: 'url',  typeAttributes: { label: { fieldName: "CreatedByName" }, tooltip:"User Name", target: "_blank" }, sortable: true }
        ,{ label: 'Scope', initialWidth: 80, fieldName: 'Scope', type: 'text', sortable: false }
        ,{ label: 'Filter', initialWidth: 1000, fieldName: 'Filter', type: 'text', sortable: false, wrapText: true }
    ];

    @track deleteList;
    @track viewList;
    @track objectTypePicklistValues;
    @track objectTypes;
    //@track selectedRecordsCount = 0; //hmmm, it seems I'm not using this anywhere
    @track retrievedRecordsCount = 0;
    @track totalRecordsCount = 0;
    @track disableButton = true;
    @track objectName
    @track sortBy = 'CreatedDate';
    @track sortDirection = 'asc';
    @track error;

    //unofficialSF
    @track confirmation;

     // non-reactive variables
     selectedRecords = [];
     recordCountMessage;
     refreshTable;
     refreshCount;
     isLoading = false;
  
    connectedCallback() {
        this.isLoading = true;
		getObjectTypePicklistValues()
			.then(data => {
				this.objectTypePicklistValues = data;
                this.isLoading = false;
			})
			.catch(error => {
				this.error = error;
                this.isLoading = false;
			});
	}

    @wire(getViewsByObjectName, {pObjectType: '$objectName', pSortBy : '$sortBy',pSortOrder : '$sortDirection'})
    wiredViews(result) {
        
        this.refreshTable = result;
        if (result.data) {
            this.retrievedRecordsCount = result.data.length;
            if (result.data.length===0){
                this.totalRecordsCount = result.data.length;
            }
            this.viewList = result.data;
            this.recordCountMessage = 'Records retrieved: '+this.retrievedRecordsCount+' of '+this.totalRecordsCount;
            this.isLoading = false;
        } else if (result.error) {
            this.error = error.body.message;
            this.isLoading = false;
        }
    }

    @wire(getViewsCountByObjectName, {pObjectType: '$objectName'})
    wiredViewsCount(result) {
       this.refreshCount = result
       if (result.data) {
           this.totalRecordsCount = result.data;
           this.recordCountMessage = 'Records retrieved: '+this.retrievedRecordsCount+' of '+this.totalRecordsCount;
       } else if (result.error) {
           this.error = error.body.message;
       }
    }

     processSelectedRecords(event) {
        const selectedRows = event.detail.selectedRows;
        this.disableButton = true;
        if(selectedRows){
            //this.selectedRecordsCount = event.detail.selectedRows.length;
            this.selectedRecords = [];
            for (let i = 0; i < selectedRows.length; i++) {
                this.disableButton = false;
                this.selectedRecords.push({ListViewId:selectedRows[i].ListViewId, Name:selectedRows[i].Name, DeveloperName:selectedRows[i].DeveloperName, ObjectType:selectedRows[i].ObjectType, Scope:selectedRows[i].Scope});
            }
        }else{
            this.disableButton = true;
            this.displayMessage = 'Please select view(s) to be deleted';
        }
        
    }
    handleSortdata(event) {
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        //assign the values. This will trigger the wire method to reload.
        this.sortBy = fieldName;
        this.sortDirection = sortDirection;
        this.isLoading = true;
     }

     deleteViews(){
        deletePublicViews({pViewRecords: JSON.stringify(this.selectedRecords)})
        .then((result) => {
            this.disableButton = true;
            this.template.querySelector('lightning-datatable').selectedRows = [];
            //this.selectedRecordsCount = 0;
            // refreshing table data using refresh apex
            refreshApex(this.refreshCount)
            return refreshApex(this.refreshTable);
        })
        .catch((error) => {
            this.error = error.body.message;
        });
   }
   //this is the picklist where the user selects what type of object he or she wishes to manage
    selectionChangeHandler(event) {
        const objectName = event.target.value;
        this.objectName = objectName;
        this.isLoading = true;
        this.error = '';
        this.disableButton = true;
	}

    //from unofficialSF
    //https://unofficialsf.com/easily-add-confirmation-dialogs-to-your-lightning-components-with-lwcmodal/
    deleteConfirmationDetails = {
        text: this.displayMessage,
        confirmButtonLabel: 'Delete',
        confirmButtonVariant: 'destructive',
        cancelButtonLabel: 'Cancel',
        header: 'Deleted Views do NOT go to the Recycle Bin'
    };
    //from unofficialSF        
    handleDeleteClick(event) {
        this.displayMessage = 'Are you sure you want to delete the following views: ';
        for (let i = 0; i < this.selectedRecords.length; i++) {
            this.displayMessage = this.displayMessage + this.selectedRecords[i].Name;
            if (i<this.selectedRecords.length-1){
                this.displayMessage = this.displayMessage + ', ';
            }
        }

        this.deleteConfirmationDetails['text'] = this.displayMessage;
        this.confirmation = getConfirmation(
            this.deleteConfirmationDetails,
            () => this.deleteViews(), 
            // optional: () => this.handleCancel()
        );
    }
    //from unofficialSF
    handleModalButtonClick(event) {
        handleConfirmationButtonClick(event, this.confirmation);
    }
    
}