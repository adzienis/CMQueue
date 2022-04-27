import consumer from "./consumer";

async function handle_data(data) {
  document.title = data === null ? "N/A" : data;
}

class TitleChannelManager {
  constructor() {
    this.update_course_channel = this.update_course_channel.bind(this);
    this.general_channel = null;
    this.role_channel = null;

    document.addEventListener("turbo:load", this.update_course_channel);


    consumer.subscriptions.create({
      channel: "TitleChannel"
    }, {
      received(data) {
        this.handle_data(data);
      },
      handle_data
    });

    this.update_course_channel();
  }

  update_course_channel() {
    const exp = /courses\/(\d+)/;

    const match = location.pathname.match(exp);

    if (match) {
      if (
          this.general_channel === null ||
          JSON.parse(this.general_channel.identifier).room !== match[1]
      ) {
        if (this.general_channel !== null) consumer.subscriptions.remove(this.general_channel);

        this.general_channel = consumer.subscriptions.create({
          channel: "TitleChannel",
          room: match[1],
          type: "general"
        }, {
          received(data) {
            this.handle_data(data);
          },
          handle_data
        });
      }

      if (
          this.role_channel === null ||
          JSON.parse(this.role_channel.identifier).room !== match[1]
      ) {
        if (this.role_channel !== null) consumer.subscriptions.remove(this.role_channel);

        this.role_channel = consumer.subscriptions.create({
          channel: "TitleChannel",
          room: match[1],
          type: "role"
        }, {
          received(data) {
            this.handle_data(data);
          },
          handle_data
        });
      }
    }
  }
}

new TitleChannelManager()