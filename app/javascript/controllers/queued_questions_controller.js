import { Controller } from "stimulus";
import React from "react";

function arrayEquals(a, b) {
  return (
    Array.isArray(a) &&
    Array.isArray(b) &&
    a.length === b.length &&
    a.every((val, index) => val === b[index])
  );
}

export default class extends Controller {
  static values = { courseId: Number };

  initialize() {
    console.log("here queue");
    window.addEventListener("page:invalidate", (event) => {
      if (
        arrayEquals(event.detail, ["courses", this.courseIdValue, "questions"])
      ) {
        console.log("we here");
        console.log(this.element);
        this.element.reload();
      }
    });
  }
}
