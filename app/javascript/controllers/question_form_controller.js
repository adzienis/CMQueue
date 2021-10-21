import { Controller } from "stimulus";
import subscribeToQuery from "../src/utilities/subscribeToQuery";

export default class extends Controller {
  static targets = ["modal"];
  static values = {
    questionId: Number,
    state: String,
    newRecord: Boolean,
    courseId: Number,
  };

  initialize() {
    let old_state = null;
    this.unsubscribe = subscribeToQuery(
      ["courses", this.courseIdValue, "current_question"],
      (result) => {
        if (result.data) {
          if (old_state !== result.data.question_state.state) {
            this.element.reload();
            old_state = result.data.question_state.state;
          }
        }
      }
    );
  }

  disconnect() {
    this.unsubscribe();
  }
}
