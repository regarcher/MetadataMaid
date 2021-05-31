//deletePublicViews.js
//source: https://github.com/regarcher/MetadataMaid
import { LightningElement, wire, track } from 'lwc';
import getViewsByObjectName from '@salesforce/apex/ViewManager.getViewsByObjectName';
import getViewsCountByObjectName from '@salesforce/apex/ViewManager.getViewsCountByObjectName';
import getObjectTypePicklistValues from '@salesforce/apex/ViewManager.getObjectTypePicklistValues';
import deletePublicViews from '@salesforce/apex/ViewManager.deletePublicViews';
import {refreshApex} from '@salesforce/apex';

export default class DeletePublicViews extends LightningElement {
    //reactive variables
    @track columns = [
        
        //{ label: 'View Name', fieldName: 'Name', type: 'text', sortable: true }
        //I just get insufficient privileges when I attempt to click these links...why?
        { label: 'View Name', initialWidth: 380, fieldName: 'LinkView', type: 'url', typeAttributes: { label: { fieldName: "Name" }, tooltip:"View Name", target: "_blank" }, sortable: true }
        ,{ label: 'Last Modified Date', initialWidth: 160, fieldName: 'LastModifiedDate', type: 'text', sortable: true }
        ,{ label: 'Created Date', initialWidth: 160, fieldName: 'CreatedDate', type: 'text', sortable: true }
        ,{ label: 'Created By', initialWidth: 180, fieldName: 'LinkUser', type: 'url',  typeAttributes: { label: { fieldName: "CreatedByName" }, tooltip:"User Name", target: "_blank" }, sortable: true }
        ,{ label: 'Scope', initialWidth: 80, fieldName: 'Scope', type: 'text', sortable: false }
        ,{ label: 'Filter', initialWidth: 1000, fieldName: 'Filter', type: 'text', sortable: false }
    ];

    @track deleteList;
    @track viewList;
    @track objectTypePicklistValues;
    @track objectTypes;
    @track selectedRecordsCount = 0;
    @track retrievedRecordsCount = 0;
    @track totalRecordsCount = 0;
    @track disableButton = false;
    @track objectName
    @track sortBy = 'CreatedDate';
    @track sortDirection = 'asc';
    @track error;

     // non-reactive variables
     selectedRecords = [];
     recordCountMessage;
     refreshTable;
     refreshCount;
     isLoading = false;
  
    //so, I simply could not get this to work with @wired and I have no idea why
    connectedCallback() {
		getObjectTypePicklistValues()
			.then(data => {
				this.objectTypePicklistValues = data;
			})
			.catch(error => {
				this.error = error;
			});
	}

    @wire(getViewsByObjectName, {pObjectType: '$objectName', pSortField : '$sortBy',pSortOrder : '$sortDirection'})
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
        this.selectedRecordsCount = event.detail.selectedRows.length;
        this.selectedRecords = [];
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedRecords.push({ListViewId:selectedRows[i].ListViewId, Name:selectedRows[i].Name, DeveloperName:selectedRows[i].DeveloperName, ObjectType:selectedRows[i].ObjectType, Scope:selectedRows[i].Scope});
        }
    }
    handleSortdata(event) {
        //Thanks to the following web site for this pattern:
        //https://www.salesforcecodecrack.com/2019/07/lightning-data-table-with-sorting.html
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        //assign the values. This will trigger the wire method to reload.
        this.sortBy = fieldName;
        this.sortDirection = sortDirection;
        this.isLoading = true;
     }

     handleDeleteViewClick(event){
        if (this.selectedRecords) {
            this.disableButton = true;
            this.deleteViews();
        }
        this.isLoading = true;
     }

     deleteViews(){
        deletePublicViews({pViewRecords: JSON.stringify(this.selectedRecords)})
        .then((result) => {
            this.disableButton = false;
            this.template.querySelector('lightning-datatable').selectedRows = [];
            this.selectedRecordsCount = 0;
            // refreshing table data using refresh apex
            refreshApex(this.refreshCount)
            return refreshApex(this.refreshTable);
        })
        .catch((error) => {
            this.error = error.body.message;
        });
   }
   
    selectionChangeHandler(event) {
        const objectName = event.target.value;
        this.objectName = objectName;
        this.isLoading = true;
        this.error = '';
        this.disableButton = false;
	}
}