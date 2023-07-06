import { LightningElement, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class WireApexController extends LightningElement {

    // binding the wire to the component property
    @wire(getAccounts)
    accounts
    
    // binding the wire to the function
    /*@wire(getAccounts)
    loadAccounts({ data, error }) {
        if (error) {
            // show error
            console.log(error);
        } else {
            console.log(data);
        }
    }*/
}