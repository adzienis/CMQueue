import { Controller } from "stimulus";

import { Modal } from "bootstrap";

export default class extends Controller {
  static targets = ["modal", "button"];

  modal = null;

  initialize() {}

  buttonTargetConnected() {
    this.buttonTarget.addEventListener("click", (e) => {
      console.log("hey");
      this.modal.show();
    });
  }

  modalTargetConnected() {
    this.modal = new Modal(this.modalTarget);
  }
}
