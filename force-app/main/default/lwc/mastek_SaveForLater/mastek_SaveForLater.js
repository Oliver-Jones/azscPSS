import tmpl from "./mastek_SaveForLater.html"
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin"
import { NavigationMixin } from "lightning/navigation"
import omniscriptSaveForLaterAcknowledge from "omnistudio/omniscriptSaveForLaterAcknowledge"

export default class Mastek_SaveForLater extends OmniscriptBaseMixin(NavigationMixin(omniscriptSaveForLaterAcknowledge)) {
    connectedCallback() {
        if(this.auto == false) {
            if(window.location.href.includes(".lightning.force.com")) {
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
                        name: window.location.href.includes(".site.com/s/sub-applications") ? "Sub_Applications__c" : "Applications__c"
                    }
                });
            }
        }
	}

    render(){
        return tmpl
    }
}