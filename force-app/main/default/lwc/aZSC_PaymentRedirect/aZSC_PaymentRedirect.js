import { LightningElement, wire } from 'lwc'
import getjBillingPaymentWebPage from '@salesforce/apex/AZSC_LightningController.getjBillingPaymentWebPage'
import { CurrentPageReference } from "lightning/navigation"
import { NavigationMixin } from "lightning/navigation"
export default class AZSC_PaymentRedirect extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference)
    currentPageRef
    showPaymentRedirect = false
    showSpinner = true

    connectedCallback() {
        console.log('session : '+sessionStorage.getItem('PaymentRedirect'))
        if(this.currentPageRef.state.c__applnId && sessionStorage.getItem('PaymentRedirect')) {
            this.showPaymentRedirect = true
            sessionStorage.removeItem('PaymentRedirect');
            getjBillingPaymentWebPage({
                applnId : this.currentPageRef.state.c__applnId
            }).then(result => {
                console.log('jBilling Order URL '+JSON.stringify(result))
                if(result.success == true) {
                    window.location.href = result.paymentURL
                }
            })
        }
        if(this.showPaymentRedirect == false) {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: this.currentPageRef.state.c__propertyValue == "exams" ? "Exams__c" : "Applications__c"
                }
            })
        }
    }
}