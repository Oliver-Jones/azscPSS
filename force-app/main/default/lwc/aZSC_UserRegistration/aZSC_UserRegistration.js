import { LightningElement, track } from 'lwc'
import { NavigationMixin } from "lightning/navigation"
import { ShowToastEvent } from "lightning/platformShowToastEvent"
import checkDupicateUser from '@salesforce/apex/AZSC_LightningController.checkDupicateUser'
import createUser from '@salesforce/apex/AZSC_LightningController.createUser'

export default class AZSC_UserRegistration extends NavigationMixin(LightningElement) {
    @track usr = {
        "accessType" : 'Business_Account'
    }
    showMessage = false

    get options() {
        return [
            { label: 'Business', value: 'Business_Account' },
            { label: 'Individual', value: 'PersonAccount' }
        ]
    }

    get isBusiness() {
        return this.usr.accessType == 'Business_Account'
    }

    handleChange(event) {
        this.usr[event.target.dataset.field] = event.target.value
    }

    handleLogin() {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                pageName: "login"
            }
        })
    }

    handleClick(event) {
        const isValid = this.validateFields()
        if(!isValid)
            return
        checkDupicateUser({"email" : this.usr.Email})
        .then(result => {
            if(result && result.length > 0) {
                this.template.querySelector("[data-field ='Email']").setCustomValidity("Duplicate Email")
                this.template.querySelector("[data-field ='Email']").reportValidity()
            }
            else {
                createUser({"params" : this.usr})
                .then(output => {
                    if(output === true) {
                        this.showMessage = true
                        this.dispatchEvent(new ShowToastEvent({
                            title: "Registration",
                            message: "Registered successfully! Kindly check your inbox to login and set password.",
                            variant: "success",
                        }))
                    }
                    else {
                        this.dispatchEvent(new ShowToastEvent({
                            title: "Registration",
                            message: "There was an error processing your request, kindly contact admin!",
                            variant: "error",
                        }))
                    }
                })
            }
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: "Registration",
                message: "There was an error processing your request, kindly contact admin!",
                variant: "error",
            }))
        })
        console.log(''+JSON.stringify(this.usr))
    }

    validateFields() {
        const inputFields = this.template.querySelectorAll('lightning-input')
        const inputRadios = this.template.querySelectorAll('lightning-radio-group')
        const allInputs = [...inputFields, ...inputRadios]
        let isValid = true
        let isFocused = false
        for(const inputField of allInputs) {
            if(inputField.required && ((inputField.type != "checkbox" && inputField.type != "checkbox-button" && !inputField.value) || ((inputField.type == "checkbox" || inputField.type == "checkbox-button") && !inputField.checked)) && inputField.type != 'file') {
                isValid = false
                inputField.reportValidity()
            }
            if(!inputField.checkValidity()) {
                isValid = false
            }
            if(isValid == false && isFocused == false) {
                inputField.focus()
                isFocused = true
            }
        }
        return isValid
    }

}