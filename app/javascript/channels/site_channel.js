import consumer from "./consumer";

consumer.subscriptions.create("SiteChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  async received(data) {
    if (data.invalidate) {
      if (process.env.NODE_ENV === "development") {
        console.log("invalidating_site", data.invalidate);
      }
    }
  },
});
