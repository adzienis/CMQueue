import { Controller } from "stimulus";

import { Modal } from "bootstrap";

export default class extends Controller {
  static targets = ["button"];
  static values = {
    id: String
  };

  modal = null;

  initialize() {
    console.log(this.idValue)
    this.modal = new Modal(document.querySelector(`#${this.idValue}`));
  }

  buttonTargetConnected() {
    this.buttonTarget.addEventListener("click", (e) => {
      this.modal.show();
    });
  }
}
