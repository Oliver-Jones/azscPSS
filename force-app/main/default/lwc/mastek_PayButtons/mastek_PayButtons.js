import { LightningElement, api } from 'lwc'
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin"
import paymentModal from 'c/mastek_PaymentModal';
export default class Mastek_PayButtons extends OmniscriptBaseMixin(LightningElement) {
    @api AppId
    @api FeeId
    async payNow() {
        const result = await paymentModal.open({
            size: 'small',
            description: '',
            payMode: 'payNow',
            onconfirm: (e) => {
                e.stopPropagation()
                this.resetValues()
                this.omniApplyCallResp({'payNow': true})
                this.omniNextStep()
            }
        })
    }

    async payLater() {
        const result = await paymentModal.open({
            size: 'small',
            description: '',
            payMode: 'payLater',
            onconfirm: (e) => {
                e.stopPropagation()
                this.resetValues()
                this.omniApplyCallResp({'payLater': true})
                this.omniNextStep()
            }
        })
    }

    resetValues() {
        this.omniApplyCallResp({'payLater': false})
        this.omniApplyCallResp({'payNow': false})
    }
}