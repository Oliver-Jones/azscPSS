import { LightningElement } from 'lwc'
import tmpl from './aZSC_SaveForLater.html'
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin'
import { NavigationMixin } from "lightning/navigation"
import omniscriptSaveForLaterAcknowledge from 'omnistudio/omniscriptSaveForLaterAcknowledge'

export default class AZSC_SaveForLater extends OmniscriptBaseMixin(NavigationMixin(omniscriptSaveForLaterAcknowledge)) {
    connectedCallback() {
        if(this.auto == false) {
            if(window.location.href.includes('.lightning.force.com')) {
                this[NavigationMixin.Navigate]({
                    type: "standard__objectPage",
                    attributes: {
                        objectApiName: "BusinessLicenseApplication",
                        actionName: "list",
                    },
                    state: {
                        filterName: "All_BusinessLicenseApplication"
                    }
                });
            }
            else {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Applications__c"
                    },
                    state: {
                        c__propertyValue: "application"
                    }
                });
            }
        }
	}

    render(){
        return tmpl
    }
}