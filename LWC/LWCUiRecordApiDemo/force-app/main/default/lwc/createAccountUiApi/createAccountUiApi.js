import { LightningElement } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import ANNUAL_REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';

export default class CreateAccountUiApi extends LightningElement {
    accountName;
    annualRevenue;
    objectApiName = ACCOUNT_OBJECT.objectApiName;
    fields = [NAME_FIELD, ANNUAL_REVENUE_FIELD];

    handleInputChange = (e) => {
        let value = e.target.value;
        if (e.target.name == 'accountName') {
            this.accountName = value;
        } else {
            this.annualRevenue = value;
        }
    }

    // Create record using LWC UI record API using custom approach
    handleCreateAccount = (e) => {
        e.preventDefault();
        const recordInput = {
            apiName: ACCOUNT_OBJECT.objectApiName,
            fields: {
                [NAME_FIELD.fieldApiName]: this.accountName,
                [ANNUAL_REVENUE_FIELD.fieldApiName]: this.annualRevenue
            }
        };

        createRecord(recordInput).then(() => {
            const success = new ShowToastEvent({
                title: 'Created successfully',
                message: 'An account has been created',
                variant: 'success'
            });
            this.dispatchEvent(success);
        }).catch(error => {
            const err = new ShowToastEvent({
                title: 'An error ocurred',
                message: error.message,
                variant: 'error'
            });
            this.dispatchEvent(err);
        })
    }
}