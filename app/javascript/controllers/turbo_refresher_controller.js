import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["frame"];
  static values = { eventName: String };

  initialize() {
    document.addEventListener(this.eventNameValue, (event) => {
      this.frameTarget.reload();
    });
  }
}
