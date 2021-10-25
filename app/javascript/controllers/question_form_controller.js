import { Controller } from "stimulus";
import subscribeToQuery from "../src/utilities/subscribeToQuery";
import Modal from "bootstrap/js/dist/modal";

export default class extends Controller {
  static targets = ["modal", "form", "body"];

  static values = {
    questionId: Number,
    state: String,
    newRecord: Boolean,
    courseId: Number,
  };

  resolvingTimer(target, state, question) {
    const elem = document.createElement("div");
    elem.classList.add("h5");

    if (state === "resolving") {
      target.innerHTML = "";
      target.appendChild(elem);
      let seconds =
        (new Date() - new Date(question.question_state.created_at)) / 1000;
      elem.innerHTML = `Your question has been resolving for ${Math.floor(
        seconds / 60
      )
        .toString()
        .padStart(2, "0")}:${Math.floor(seconds % 60)
        .toString()
        .padStart(2, "0")}`;
      setInterval(() => {
        seconds =
          (new Date() - new Date(question.question_state.created_at)) / 1000;
        elem.innerHTML = `Your question has been resolving for ${Math.floor(
          seconds / 60
        )
          .toString()
          .padStart(2, "0")}:${Math.floor(seconds % 60)
          .toString()
          .padStart(2, "0")}`;
      }, 1000);
    }
  }

  initialize() {
    let old_state = null;
    this.modal = Modal.getOrCreateInstance(this.modalTarget);

    this.unsubscribe = subscribeToQuery(
      ["courses", this.courseIdValue, "current_question"],
      (result) => {
        if (result.data) {
          if (old_state !== result.data.question_state.state) {
            old_state = result.data.question_state.state;
            if (["unresolved"].includes(old_state)) {
              this.modal.hide();
            }

            this.formTarget.reload();

            this.formTarget.loaded.then((suc) => {
              if (this.hasBodyTarget) {
                this.resolvingTimer(
                  this.bodyTarget,
                  result.data.question_state.state,
                  result.data
                );
              }

              if (["resolving", "frozen"].includes(old_state)) {
                this.modal.show();
              } else {
                this.modal.hide();
              }
            });
          }
        }
      }
    );
  }

  disconnect() {
    this.unsubscribe();
  }
}
