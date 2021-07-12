import {Controller} from 'stimulus'

export default class extends Controller {

    static targets = ["submit"]

    originalValues = new Map;
    disabled = false;

    initialize() {
    }

    connect() {
        const inputElements = [...this.element.querySelectorAll("input,textarea")].filter(v => v.name !== "authenticity_token")

        this.submitTarget.disabled = true

        inputElements.forEach(v => {

            if(v.classList.contains("is-invalid")) {
                this.originalValues.set(v, null);
                this.submitTarget.disabled = false;

            }else {
                this.originalValues.set(v, v.value);
            }

            v.oninput = e => {
                if(e.target.value !== this.originalValues.get(e.target)) this.disabled = true;

                let anyChanged = false;

                inputElements.forEach(elem => {
                    if(elem.value !== this.originalValues.get(elem)){
                        anyChanged = true;
                    }
                })

                this.disabled = anyChanged
                this.submitTarget.disabled = !this.disabled
            }
        })

        const values = [...inputElements].map(v => v.value)
    }

    disconnect() {
    }
}