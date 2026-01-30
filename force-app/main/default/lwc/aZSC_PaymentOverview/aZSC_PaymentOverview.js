import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { OmniscriptActionCommonUtil } from 'omnistudio/omniscriptActionUtils';
import { NavigationMixin } from "lightning/navigation";
import paymentModal from 'c/aZSC_PaymentNoteModal';
import getjBillingPaymentWebPage from '@salesforce/apex/AZSC_LightningController.getjBillingPaymentWebPage'
import updateApplnStatusToPaymentPending from '@salesforce/apex/AZSC_LightningController.UpdateApplnStatusToPaymentPending'
export default class AZSC_PaymentOverview extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
    @api hidePayLater
    async payNow() {
        const result = await paymentModal.open({
            size: 'small',
            description: '',
            payMode: 'PayNow',
            onconfirm: (e) => {
                e.stopPropagation()
                this.resetValues()
                this.omniApplyCallResp({'PayNow': true})
                sessionStorage.setItem('PaymentRedirect', true)
                this.omniNextStep()
            }
        })
    }

    async payLater() {
        const result = await paymentModal.open({
            size: 'small',
            description: '',
            payMode: 'PayLater',
            onconfirm: (e) => {
                e.stopPropagation()
                this.resetValues()
                this.omniApplyCallResp({'PayLater': true})
                this.omniNextStep()
            }
        })
    }

    resetValues() {
        this.omniApplyCallResp({'PayLater': false})
        this.omniApplyCallResp({'PayNow': false})
    }


/*
    showSpinner = false
    //@api regId
    //@api appId
    //@api isPortalEnabled
    tableData = []
    tableInfo = []
    showTable = false
    feeTotal = ''
    payMode = "paylater"

    get isPayLater() {
        return this.payMode == "paylater"
    }

    get isPayNow() {
        return this.payMode == "paynow"
    }
    
    connectedCallback() {
        this._actionUtilClass = new OmniscriptActionCommonUtil();
        const params = {
            input: '{"regTrxnFeeId" : "'+this.regId+'"}',
            sClassName: 'AZSC_OmniScriptUtilities',
            sMethodName: 'getRegTrxnFeeItems',
            options: '{}',
        };
        this._actionUtilClass.executeAction(params, null, this, null, null).then(response => {
            if(response.result) {
                this.tableData = JSON.parse(response.result.FeeItemList);
                this.feeTotal = JSON.parse(response.result.FeeTotal);
                for(var key in this.tableData) {
                    this.showTable = true;
                    this.tableInfo.push({value:this.tableData[key], key:key});
                }
            }
        }).catch(error => {
            let customError = {
                "CustomError" : "Error: " + error
            }
        });
    }

    async payNow() {
        const result = await paymentModal.open({
            size: 'large',
            description: '',
            payMode: 'paynow',
            applnId: this.appId,
            onconfirm: (e) => {
                e.stopPropagation()
                this.showTable = false
                this.showSpinner = true
                getjBillingPaymentWebPage({
                    applnId : this.appId
                }).then(result => {
                    console.log('jBilling Order URL '+JSON.stringify(result))
                    if(result.success == true) {
                        window.location.href = result.paymentURL
                    }
                })
                //this.resetValues()
                //this.omniApplyCallResp({'PayNow': true})
                //this.omniNextStep()
            },
        })
    }

    async payLater() {
        const result = await paymentModal.open({
            size: 'large',
            description: '',
            payMode: 'paylater',
            applnId: this.appId,
            onconfirm: (e) => {
                e.stopPropagation()
                this.showSpinner = true
                this.showTable = false
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        recordId: this.appId,
                        actionName: "view",
                        objectApiName: "BusinessLicenseApplication"
                    }
                })
                //this.resetValues()
                //this.omniApplyCallResp({'PayLater': true})
                //this.omniNextStep()
            },
        })
    }*/
}