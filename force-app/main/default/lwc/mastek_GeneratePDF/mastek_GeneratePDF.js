import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import generatePDF from "@salesforce/apex/MastekOmnistudioController.generateApplicationPDF"

export default class Mastek_GeneratePDF extends LightningElement {
    _recordId;
    @api set recordId(value) {
        this._recordId = value;
        generatePDF({ recordId: value, templateAPI: 'OSHA_Certificate_Template', docTitle: 'ApplicationPDF' })
        .then(output => {
            // Close the modal window and display a success toast
            this.dispatchEvent(new CloseActionScreenEvent());
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'PDF generated Successfully!',
                    variant: 'success'
                })
            );
            refreshApex()
            //window.location.reload()
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