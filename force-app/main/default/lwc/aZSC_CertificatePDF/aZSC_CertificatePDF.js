import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from "lightning/navigation"
import generatePDF from "@salesforce/apex/AZSC_LightningController.generateServerSidePDF"

export default class AZSC_CertificatePDF extends NavigationMixin(LightningElement) {
    _recordId;
    @api set recordId(value) {
        this._recordId = value;
        generatePDF({ recordId: value })
        .then(output => {
            console.log('output '+JSON.stringify(output));
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'PDF generated Successfully!',
                    variant: 'success'
                })
            );
            // Close the modal window and display a success toast
            //setTimeout(() => {
                
                /*let relatedListURL = {
                    type: "standard__recordRelationshipPage",
                    attributes: {
                        recordId: value,
                        objectApiName: this.objectApiName,
                        relationshipApiName: "AttachedContentDocuments",
                        actionName: "view",
                    },
                }
                this[ NavigationMixin.GenerateUrl ]( relatedListURL )
                .then(url => window.open( url, '_self' ))*/
                /*let baseUrl = 'https://'+location.host
                let downloadUrl = baseUrl+'/sfc/servlet.shepherd/document/download';
                this.selDocRows.forEach(file => {
                    downloadUrl = downloadUrl + '/'+file.DocId
                })
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                    url: downloadUrl
                    }
                }, true );  */
            //}, "5000");
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There was an error processing your request, kindly contact admin!',
                    variant: 'error'
                })
            );
        })
    }

    get recordId() {
        return this._recordId;
    }

    @api objectApiName;
}