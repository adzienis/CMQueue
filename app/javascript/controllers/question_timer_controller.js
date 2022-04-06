import {Controller} from "stimulus";

export default class extends Controller {
    interval = null
    static values = {createdAt: String};

    initialize() {
        this.interval = setInterval(() => {
            const seconds = Math.floor(((new Date()) - (new Date(this.createdAtValue))) / 1000)
            const output = `${Math.floor(seconds/60 % 60).toString(10).padStart(2, "0")}:${(seconds % 60).toString(10).padStart(2, "0")}`
            this.element.innerHTML = output
        }, 1000)
    }

    disconnect() {
        if (this.interval !== null)
            clearInterval(this.interval)
    }
}