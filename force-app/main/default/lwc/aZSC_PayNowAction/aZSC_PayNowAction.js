import { LightningElement,api } from 'lwc'
import { CloseActionScreenEvent } from 'lightning/actions'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getjBillingPaymentWebPage from '@salesforce/apex/AZSC_LightningController.getjBillingPaymentWebPage'
export default class AZSC_PayNowAction extends LightningElement {
     _recordId
    @api set recordId(value) {
        this._recordId = value;
        getjBillingPaymentWebPage({
            applnId : value
        }).then(result => {
            console.log('jBilling Order URL '+JSON.stringify(result))
            if(result.success == true) {
                window.location.href = result.paymentURL
                this.showSpinner = false
                this.dispatchEvent(new CloseActionScreenEvent())
            }
            else {
                this.dispatchEvent(new CloseActionScreenEvent())
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'There was an error processing your request, kindly contact admin!',
                        variant: 'error'
                    })
                )
            }
        })
        .catch(error => {
            this.dispatchEvent(new CloseActionScreenEvent())
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There was an error processing your request, kindly contact admin!',
                    variant: 'error'
                })
            )
        })
    }

    get recordId() {
        return this._recordId;
    }

    @api objectApiName;
}