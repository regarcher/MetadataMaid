//deletePrivateDashboards.js
//source: https://github.com/regarcher/MetadataMaid
import { LightningElement, wire, track } from 'lwc';
import getInactiveUsersAndDashboardWrappersWithParams from '@salesforce/apex/DashboardManager.getInactiveUsersAndDashboardWrappersWithParams';
import deletePrivateDashboardsById from '@salesforce/apex/DashboardManager.deletePrivateDashboardsById';
import getPrivateDashboardsInactiveUsersCount from '@salesforce/apex/DashboardManager.getPrivateDashboardsInactiveUsersCount';
import {refreshApex} from '@salesforce/apex';

export default class deletePrivateDashboards extends LightningElement {
   //reactive variables
    @track columns = [
        { label: 'User Name', fieldName: 'LinkUser', type: 'url',  typeAttributes: { label: { fieldName: "CreatedByName" }, tooltip:"User Name", target: "_blank" }, sortable: true }
        ,{ label: 'Dashboard Title', fieldName: 'Title', type: 'text', sortable: false }
        ,{ label: 'Dashboard Last Modified', fieldName: 'DashboardLastModified', type: 'text', sortable: true }
        ,{ label: 'User Profile', fieldName: 'ProfileName', type: 'text', sortable: true }
        ,{ label: 'User Last Login', fieldName: 'LastLogin', type: 'text', sortable: true }
    ];

    @track dashboardList;
    @track selectedRecordsCount = 0;
    @track retrievedRecordsCount = 0;
    @track totalRecordsCount = 0;
    @track disableButton = false;
    @track sortBy = 'CreatedByName';
    @track sortDirection = 'asc';
    @track error;


     // non-reactive variables
     selectedRecords = [];
     recordCountMessage;
     refreshTable;
     refreshCount;
    

     @wire(getPrivateDashboardsInactiveUsersCount)
     wiredDashboardCount(result) {
        this.refreshCount = result
        if (result.data) {
            this.totalRecordsCount = result.data;
            this.recordCountMessage = 'Records retrieved: '+this.retrievedRecordsCount+' of '+this.totalRecordsCount;
        } else if (result.error) {
            this.error = error.body.message;
        }
     }

    //@wire(getInactiveUsersAndDashboardWrappers)
    @wire(getInactiveUsersAndDashboardWrappersWithParams, {pSortField : '$sortBy',pSortOrder : '$sortDirection'})
    wiredDashboards(result) {
        this.refreshTable = result;
        if (result.data) {
            this.retrievedRecordsCount = result.data.length;
            if (result.data.length===0){
                this.totalRecordsCount = result.data.length;
            }
            this.dashboardList = result.data;
            this.recordCountMessage = 'Records retrieved: '+this.retrievedRecordsCount+' of '+this.totalRecordsCount;
        } else if (result.error) {
            this.error = error.body.message;
        }
    }

    processSelectedRecords(event) {
        //thanks to the following web site for the pattern on this
        //https://www.salesforcecodecrack.com/2019/06/delete-multiple-selected-records.html
        //ensure that all of the selected rows are represented in this.selectedRecords array
         const selectedRows = event.detail.selectedRows;
         this.selectedRecordsCount = event.detail.selectedRows.length;
         let conIds = new Set();
         for (let i = 0; i < selectedRows.length; i++) {
             conIds.add(selectedRows[i].DashboardId);
         }
         this.selectedRecords = Array.from(conIds);
    }

    handleDeletePrivateClick() {
        if (this.selectedRecords) {
            this.disableButton = true;
            this.deleteDashboards();
        }
    }

   deleteDashboards(){
        deletePrivateDashboardsById({pDashboardIds: this.selectedRecords})
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
   
   handleSortdata(event) {
       //Thanks to the following web site for this pattern:
       //https://www.salesforcecodecrack.com/2019/07/lightning-data-table-with-sorting.html
       let fieldName = event.detail.fieldName;
       let sortDirection = event.detail.sortDirection;
       //assign the values. This will trigger the wire method to reload.
       this.sortBy = fieldName;
       this.sortDirection = sortDirection;
    }
}