import { LightningElement, wire, track } from 'lwc'
import { CloseActionScreenEvent } from 'lightning/actions'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getPicklistValues } from "lightning/uiObjectInfoApi"
import APPLNTYPE_FIELD from "@salesforce/schema/BusinessLicenseApplication.ApplicationType"
import APPLNCATEGORY_FIELD from "@salesforce/schema/BusinessLicenseApplication.Category"
export default class AZSC_LaunchApplication extends LightningElement {
    @track
    appRec = {
        'ApplicationType' : 'Initial Licensure'
    }
    applnTypes = [
        {"label" : "Initial Licensure", "value" : "Initial Licensure"},
        {"label" : "Renewal Licensure", "value" : "Renewal"},
        {"label" : "Reinstatement Application", "value" : "Recertification"},
    ]
    applnCategories = [
        {"label" : "International", "value" : "International Applicant"},
        {"label" : "Large - non-Law Firm", "value" : "Large non-Law Firm"},
        {"label" : "Small - non-Law Firm", "value" : "Small non-Law Firm"},
        {"label" : "Non-Profit - Non-Arizona", "value" : "Non-Profit – non-Arizona"},
        {"label" : "Non-Profit - Arizona", "value" : "Non-Profit – Arizona"},
        {"label" : "Traditional Law Firm", "value" : "Traditional Law Firm"}
    ]
    /*applnCategories = [
        {"label" : "Designated Principal Sub Application", "value" : "/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=c:aZSCSubApplnDesignatedPrincipalEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=Designated Principal Sub Application"},
        {"label" : "Compliance Lawyer Sub Application", "value" : "/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=c:aZSCSubApplnComplianceLawyerEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=Compliance Lawyer Sub Application"},
        {"label" : "Authorized Individual Sub Application", "value" : "/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=c:aZSCSubApplnAuthorizedPersonEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=Authorized Person Sub Application"},
        {"label" : "Authorized Entity Sub Application", "value" : "/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=c:aZSCSubApplnAuthorizedEntityEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=Authorized Entity Sub Application"},
    ]*/

    get disableLaunch() {
        return !(this.appRec.ApplicationType && this.appRec.ApplicationCategory)
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: APPLNTYPE_FIELD })
    applnTypeResults({ error, data }) {
        //if(data)
            //this.applnTypes = data.values
    }

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: APPLNCATEGORY_FIELD })
    applnCategoryResults({ error, data }) {
        //if(data)
            //this.applnCategories = data.values
    }

    handleChange(event) {
        this.appRec[event.target.dataset.field] = event.detail.value
        console.log('this.appRec '+JSON.stringify(this.appRec))
    }

    openOmniScript() {
        let url = '/lightning/cmp/omnistudio__vlocityLWCOmniWrapper?c__target=c:aZSCInitialApplicationEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__tabLabel=Initial Application&c__applnType='+this.appRec['ApplicationType']+'&c__applnCategory='+this.appRec['ApplicationCategory']
        //write any logics here...
        window.open(url, '_blank');
    }
}