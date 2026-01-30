import tmpl from './aZSC_SaveForLaterSubAppln.html'
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin'
import { NavigationMixin } from "lightning/navigation"
import omniscriptSaveForLaterAcknowledge from 'omnistudio/omniscriptSaveForLaterAcknowledge'

export default class AZSC_SaveForLaterSubAppln extends OmniscriptBaseMixin(NavigationMixin(omniscriptSaveForLaterAcknowledge)) {
    connectedCallback() {
        if(this.auto == false) {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Sub_Applications__c"
                }
            });
        }
	}

    render(){
        return tmpl
    }
}