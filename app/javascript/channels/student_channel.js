import consumer from "./consumer";

consumer.subscriptions.create("StudentChannel", {
  connected() {},

  disconnected() {},

  received(data) {
  },
});
