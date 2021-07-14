import {Controller} from 'stimulus'
import Modal from 'bootstrap/js/dist/modal'

export default class extends Controller {

    static targets = ["modal"]

    initialize() {
        this.modal = Modal.getOrCreateInstance(this.modalTarget)

        this.modal.show()
    }

    clearModalRemnants() {
        // reset the body to original, and remove extra backdrop
        //document.body.style.overflow = "inherit"
        //document.body.style.paddingRight = "0px"
        const backdrop = document.querySelector(".modal-backdrop")
        if (backdrop) backdrop.remove()

    }

    disconnect() {
        this.modal.hide()

        this.clearModalRemnants()
    }
}