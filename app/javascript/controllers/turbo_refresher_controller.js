import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["frame"];
  static values = { eventName: String };

  initialize() {
    document.addEventListener(this.eventNameValue, (event) => {
      console.log("listening", this.eventNameValue);
      if (this.frameTarget.src == null) {
        this.frameTarget.src = null;
        this.frameTarget.src = "/courses/1/feed";
      } else {
        this.frameTarget.reload();
      }
    });
  }
}
