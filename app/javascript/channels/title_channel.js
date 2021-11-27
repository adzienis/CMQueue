import consumer from "./consumer";

consumer.subscriptions.create("TitleChannel", {
  connected() {
    this.update_course_channel = this.update_course_channel.bind(this);
    this.general_channel = null;
    this.role_channel = null;

    document.addEventListener("turbo:load", this.update_course_channel);

    this.update_course_channel();
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  async received(data) {
    document.title = data === null ? "N/A" : data;
  },

  update_course_channel() {
    const exp = /courses\/(\d+)/;

    const match = location.pathname.match(exp);

    if (match) {
      if (
        this.general_channel === null ||
        JSON.parse(this.general_channel.identifier).room !== match[1]
      ) {
        if (this.general_channel !== null)
          consumer.subscriptions.remove(this.general_channel);

        this.general_channel = consumer.subscriptions.create({
          channel: "TitleChannel",
          room: match[1],
          type: "general",
        });
        this.general_channel.received = async (data) => {
          document.title = data === null ? "N/A" : data;
        };
      }

      if (
        this.role_channel === null ||
        JSON.parse(this.role_channel.identifier).room !== parseInt(match[1], 10)
      ) {
        if (this.role_channel !== null)
          consumer.subscriptions.remove(this.role_channel);

        this.role_channel = consumer.subscriptions.create({
          channel: "TitleChannel",
          room: match[1],
          type: "role",
        });
        this.role_channel.received = async (data) => {
          document.title = data === null ? "N/A" : data;
        };
      }
    }
  },
});
