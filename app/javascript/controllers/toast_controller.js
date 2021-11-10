import { Controller } from "stimulus";
import { Toast } from "bootstrap";

export default class extends Controller {
  static targets = ["closeButton"];

  toast = null;

  initialize() {
    this.toast = new Toast(this.element, {
      autohide: false,
    });

    this.toast.show();
  }

  closeButtonTargetConnected() {
    this.closeButtonTarget.addEventListener("click", () => {
      this.toast.hide();
    });
  }
}
