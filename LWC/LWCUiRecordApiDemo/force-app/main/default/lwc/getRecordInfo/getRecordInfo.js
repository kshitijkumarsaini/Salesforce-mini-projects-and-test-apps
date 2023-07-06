import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import ANNUAL_REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';

export default class GetRecordInfo extends LightningElement {
    @api recordId;

    // Custom approach to get record Information using Wire Adaptors
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD, ANNUAL_REVENUE_FIELD] })
    account;

    get accountName() {
        return getFieldValue(this.account.data, NAME_FIELD);
    }

    get annualRevenue() {
        return getFieldDisplayValue(this.account.data, ANNUAL_REVENUE_FIELD);
    }
}