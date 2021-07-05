import consumer from "./consumer"
import queryClient from "../src/utilities/queryClientFile";

consumer.subscriptions.create("SiteChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  async received(data) {

    if(data.invalidate) {
      await queryClient.invalidateQueries(data.invalidate);

      await queryClient.refetchQueries(data.invalidate);
    }
  }
});
