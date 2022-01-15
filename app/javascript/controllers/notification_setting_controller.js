import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["input", "form"];

  checkNotificationPromise() {
    try {
      Notification.requestPermission().then();
    } catch (e) {
      return false;
    }

    return true;
  }

  handlePermission(permission) {
    // set the button to shown or hidden, depending on what the user answers
    if (
      Notification.permission === "denied" ||
      Notification.permission === "default"
    ) {
    } else {
      this.formTarget.requestSubmit();
    }
  }

  askNotificationPermission() {
    // Let's check if the browser supports notifications
    if (!("Notification" in window)) {
      console.log("This browser does not support notifications.");
    } else {
      if (this.checkNotificationPromise()) {
        Notification.requestPermission().then((permission) => {
          this.handlePermission(permission);
        });
      } else {
        Notification.requestPermission(function(permission) {
          this.handlePermission(permission);
        });
      }
    }
  }

  initialize() {
  }

  inputTargetConnected() {
    this.inputTarget.addEventListener("click", (e) => {
      if (this.inputTarget.checked) {
        this.askNotificationPermission();
      } else {
        this.formTarget.requestSubmit();
      }
    });
  }
}
