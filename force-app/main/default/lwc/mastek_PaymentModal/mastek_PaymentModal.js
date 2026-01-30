import { api } from "lwc"
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin"
import LightningModal from "lightning/modal"
import { NavigationMixin } from "lightning/navigation"
export default class Mastek_PaymentModal extends OmniscriptBaseMixin(NavigationMixin(LightningModal)) {
    @api payMode
    get isPayLater() {
        return this.payMode == "payLater"
    }

    get isPayNow() {
        return this.payMode == "payNow"
    }

    confirmClose() {
        this.dispatchEvent(new CustomEvent('confirm'))
        this.closeModal()
    }

    closeModal() {
        this.close("exit")
    }
}