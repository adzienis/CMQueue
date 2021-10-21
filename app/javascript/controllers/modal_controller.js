import { Controller } from "stimulus";
import Modal from "bootstrap/js/dist/modal";
import subscribeToQuery from "../src/utilities/subscribeToQuery";

export default class extends Controller {
  static targets = ["modal", "body"];
  static values = { questionId: Number, state: String };

  initialize() {
    this.modal = Modal.getOrCreateInstance(this.modalTarget);

    this.unsubscribe = subscribeToQuery(
      ["questions", this.questionIdValue],
      (result) => {
        if (
          typeof result.data !== "undefined" &&
          result.data.question_state.state !== "unresolved"
        ) {
          this.modal.show();

          const elem = document.createElement("div");
          elem.classList.add("h5");

          if (this.stateValue === "resolving") {
            this.bodyTarget.innerHTML = "";
            this.bodyTarget.appendChild(elem);
            let seconds =
              (new Date() - new Date(result.data.question_state.created_at)) /
              1000;
            elem.innerHTML = `Your question has been resolving for ${Math.floor(
              seconds / 60
            )
              .toString()
              .padStart(2, "0")}:${Math.floor(seconds % 60)
              .toString()
              .padStart(2, "0")}`;
            setInterval(() => {
              seconds =
                (new Date() - new Date(result.data.question_state.created_at)) /
                1000;
              elem.innerHTML = `Your question has been resolving for ${Math.floor(
                seconds / 60
              )
                .toString()
                .padStart(2, "0")}:${Math.floor(seconds % 60)
                .toString()
                .padStart(2, "0")}`;
            }, 1000);
          }
        } else {
          this.modal.hide();
          this.clearModalRemnants();
        }
      }
    );
  }

  clearModalRemnants() {
    // reset the body to original, and remove extra backdrop
    document.body.style.overflow = "inherit";
    document.body.style.paddingRight = "0px";
    const backdrop = document.querySelector(".modal-backdrop");
    if (backdrop) backdrop.remove();
  }

  disconnect() {
    this.modal.hide();
    this.clearModalRemnants();
    this.unsubscribe();
  }
}
