import { track, wire, api } from "lwc"
import LightningModal from "lightning/modal"
import { getPicklistValues } from "lightning/uiObjectInfoApi"
import APPLNTYPE_FIELD from "@salesforce/schema/BusinessLicenseApplication.ApplicationType"
import APPLNCATEGORY_FIELD from "@salesforce/schema/BusinessLicenseApplication.Applicant_Applied_as__c"
import RENEWALREASON_FIELD from "@salesforce/schema/BusinessLicenseApplication.Renewal_Reason__c"
import { NavigationMixin } from "lightning/navigation"
import pubsub from 'omnistudio/pubsub'
export default class AZSC_ApplnLaunchModal extends NavigationMixin(LightningModal) {
    @track
    appRec = {
        'ApplicationType' : 'Initial Licensure', 'RenewalType' : 'ABS Renewal'
    }
    @track applnTypes = []
    @track applnCategories = []
    @track applnRenewalTypes = []
    @api license
    @api appType
    @api flexCard

    get record() {
        return this.license
    }

    get modalTitle() {
        return (this.appType == 'Renewal' ? 'Renew' : 'New') + ' ' + (this.record?.LicenseName.includes("Alternative Business Structure") ? "ABS" : "ABS") + ' ' + 'Application'
    }

    get disableLaunch() {
        return !(this.appRec.ApplicationType && ((this.isRenewal && this.appRec.RenewalType) || (!this.isRenewal && this.appRec.ApplicationCategory)))
    }

    get isRenewal() {
        return this.appType == 'Renewal'
    }
    
    /*applnTypes = [
        {"label" : "Initial Licensure", "value" : "Initial Licensure"},
        {"label" : "Renewal Licensure", "value" : "Renewal"},
        {"label" : "Reinstatement Application", "value" : "Recertification"},
    ]
    applnCategories = [
        {"label" : "Nonprofit ABS", "value" : "Non-Profit ABS"},
        {"label" : "Equity ABS", "value" : "Equity ABS"},
        {"label" : "Regular ABS", "value" : "Regular ABS"}
    ]
    applnCategories = [
        {"label" : "International", "value" : "International Applicant"},
        {"label" : "Large - non-Law Firm", "value" : "Large non-Law Firm"},
        {"label" : "Small - non-Law Firm", "value" : "Small non-Law Firm"},
        {"label" : "Non-Profit - Non-Arizona", "value" : "Non-Profit – non-Arizona"},
        {"label" : "Non-Profit - Arizona", "value" : "Non-Profit – Arizona"},
        {"label" : "Traditional Law Firm", "value" : "Traditional Law Firm"}
    ]*/

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: APPLNTYPE_FIELD })
    applnTypeResults({ error, data }) {
        if(data) {
            this.applnTypes = data.values
            let contain = this.applnTypes.filter(typ => typ.value.includes(this.appType))
            console.log('ApplicationType : ', contain[0])
            if(contain[0])
                this.appRec.ApplicationType = contain[0].value
        }
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: APPLNCATEGORY_FIELD })
    applnCategoryResults({ error, data }) {
        if(data)
            this.applnCategories = data.values
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: RENEWALREASON_FIELD })
    applnRenewalReasonResults({ error, data }) {
        if(data)
            this.applnRenewalTypes = data.values
    }

    connectedCallback() {
        console.log('ApplicationCategory : ', JSON.stringify(this.record))
        if(this.record?.BusinessType)
            this.appRec.ApplicationCategory = this.record.BusinessType
    }

    handleChange(event) {
        this.appRec[event.target.dataset.field] = event.detail.value
        //console.log('this.appRec '+JSON.stringify(this.appRec))
    }

    confirmClose() {
        if(this.appType.includes('Initial')) {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "ABS_Application__c"
                },
                state: {
                    c__applnType : this.appRec['ApplicationType'],
                    c__applnCategory : this.appRec['ApplicationCategory']
                }
            })
        }
        else if(this.appType.includes('Renewal')) {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Renewal_ABS_Application__c"
                },
                state: {
                    c__applnType : this.appRec['ApplicationType'],
                    c__applnRenewalType : this.appRec['RenewalType'],
                    c__licenseId : this.record?.LicenseId,
                    c__role : this.record?.Role
                }
            })
        }
        this.closeModal()
    }

    closeModal() {
        if(this.flexCard)
            pubsub.fire('closelwc', 'event')
        else
            this.close("exit")
    }
}