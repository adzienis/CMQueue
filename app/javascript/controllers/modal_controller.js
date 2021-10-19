import { Controller } from "stimulus";
import Modal from "bootstrap/js/dist/modal";
import queryClient from "../src/utilities/queryClientFile";
import { QueryObserver } from "react-query";
import subscribeToQuery from "../src/utilities/subscribeToQuery";

export default class extends Controller {
  static targets = ["modal"];
  static values = { questionId: Number };

  initialize() {
    this.modal = Modal.getOrCreateInstance(this.modalTarget);

    this.unsubscribe = subscribeToQuery(
      ["questions", this.questionIdValue],
      (result) => {
        console.log("stimulus", result.data);
        if (
          typeof result.data !== "undefined" &&
          result.data.question_state.state !== "unresolved"
        ) {
          this.modal.show();
        } else {
          this.modal.hide();
          this.clearModalRemnants();
        }
      }
    );
  }

  clearModalRemnants() {
    // reset the body to original, and remove extra backdrop
    //document.body.style.overflow = "inherit"
    //document.body.style.paddingRight = "0px"
    const backdrop = document.querySelector(".modal-backdrop");
    if (backdrop) backdrop.remove();
  }

  disconnect() {
    this.modal.hide();
    this.unsubscribe();
  }
}
