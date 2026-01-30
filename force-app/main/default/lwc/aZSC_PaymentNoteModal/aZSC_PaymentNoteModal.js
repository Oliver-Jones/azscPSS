import { api } from "lwc"
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin"
import LightningModal from "lightning/modal"
import { NavigationMixin } from "lightning/navigation"
import pubsub from 'omnistudio/pubsub'
import getjBillingPaymentWebPage from '@salesforce/apex/AZSC_LightningController.getjBillingPaymentWebPage'
import updateApplnStatusToPaymentPending from '@salesforce/apex/AZSC_LightningController.UpdateApplnStatusToPaymentPending'
export default class AZSC_PaymentNoteModal extends OmniscriptBaseMixin(NavigationMixin(LightningModal)) {
    @api payMode
    @api application
    @api flexCard
    @api applnId
    @api exams
    showSpinner = false

    get record() {
        return this.application
    }

    get isPayLater() {
        return this.payMode == "PayLater"
    }

    get isPayNow() {
        return this.payMode == "PayNow"
    }

    confirmClose() {
        if(this.isPayNow) {
            sessionStorage.setItem('PaymentRedirect', true)
            if(this.flexCard) {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Payment__c"
                    },
                    state: {
                        c__propertyValue: this.exams ? 'exam' : 'application',
                        c__applnId: this.record.ApplnId
                    }
                })
            }
        }
        this.dispatchEvent(new CustomEvent('confirm'))
        this.closeModal()
    }

    /*confirmClose() {
        console.log('flexCard '+JSON.stringify(this.record))
        this.showSpinner = true
        let appId = this.flexCard ? this.record.ApplnId : this.applnId
        updateApplnStatusToPaymentPending({
            recordId : appId
        }).then(result => {
            if(this.isPayNow) {
                if(window.top.location.href.includes('/applications')) {
                    sessionStorage.setItem('redirected', true);
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "Payment__c"
                        },
                        state: {
                            c__propertyValue: 'application',
                            c__applnId: appId
                        }
                    })
                }
                else {
                    this.dispatchEvent(new CustomEvent('confirm', {}))
                }
            }
            else if(this.isPayLater) {
                if(window.top.location.href.includes('/applications')) {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "Applications__c"
                        },
                        state: {
                            c__propertyValue: 'application'
                        }
                    })
                }
                else {
                    this.dispatchEvent(new CustomEvent('confirm', {}))
                }
            }
            this.closeModal()
        })
    }*/

    /*confirmClose() {
        this.showSpinner = true
        console.log('applnId '+this.applnId)
        updateApplnStatusToPaymentPending({
            recordId : this.applnId
        }).then(result => {
            if(this.isPayLater) {
                console.log('Portal '+this.isPortalEnabled+' appId '+this.applnId)
                if(this.isPortalEnabled == true) {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "Applications__c"
                        },
                        state: {
                            c__propertyValue: 'application'
                        }
                    })
                }
                else {
                    const pageRef = {
                        type: "standard__recordPage",
                        attributes: {
                            recordId: this.applnId,
                            actionName: "view",
                            objectApiName: "BusinessLicenseApplication"
                        }
                    }
                    this.dispatchEvent(new CustomEvent("navigate", {
                        bubbles: true,
                        composed: true,
                        detail: pageRef,
                    }))
                }
                this.showSpinner = false
                this.close("exit")
            }
            else if(this.isPayNow) {
                if(this.isPortalEnabled != true || window.top.location.href.includes('/applications')) {
                    getjBillingPaymentWebPage({
                        applnId : this.applnId
                    }).then(result => {
                        console.log('jBilling Order URL '+JSON.stringify(result))
                        if(result.success == true) {
                            window.location.href = result.paymentURL
                            this.showSpinner = false
                            this.close("exit")
                        }
                    })
                }
                else {
                    sessionStorage.setItem('redirected', true);
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "Applications__c"
                        },
                        state: {
                            c__propertyValue: 'application',
                            c__applnId: this.applnId
                        }
                    })
                    this.showSpinner = false
                    this.close("exit")
                }
            }
        })
        .catch(error => {
            this.showSpinner = false
            console.log(error)
        })
    }*/

    closeModal() {
        if(this.flexCard)
            pubsub.fire('closelwc', 'event')
        else
            this.close("exit")
    }
}