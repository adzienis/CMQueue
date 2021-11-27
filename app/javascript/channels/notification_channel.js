import consumer from "./consumer";

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if (
      Notification.permission !== "denied" &&
      Notification.permission !== "default"
    ) {
      if (document.hasFocus()) return;
      new Notification("CMQueue", {
        body: data.params.message,
      });
    }
  },
});
