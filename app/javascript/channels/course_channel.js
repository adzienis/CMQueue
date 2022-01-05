import consumer from "./consumer";

consumer.subscriptions.create("CourseChannel", {
  connected() {
    this.update_course_channel = this.update_course_channel.bind(this);
    this.general_channel = null;
    this.role_channel = null;
    this.enrollment_channel = null;

    document.addEventListener("turbo:load", this.update_course_channel);

    this.update_course_channel();
  },

  disconnected() {
    document.removeEventListener("turbo:load", this.update_course_channel);
    if(this.general_channel !== null)
      consumer.subscriptions.remove(this.general_channel);
    if(this.role_channel !== null)
      consumer.subscriptions.remove(this.role_channel);
    if (this.enrollment_channel !== null)
      consumer.subscriptions.remove(this.enrollment_channel);
  },

  received(data) {
  },
  async handle_data(data) {
    if (data.type === "event") {
      if (typeof data.payload !== undefined) {
        const event = new CustomEvent(data.event, {
          detail: data.payload
        });
        document.dispatchEvent(event);
      } else {
        const event = new Event(data.event);
        document.dispatchEvent(event);
      }
    }
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
          channel: "CourseChannel",
          room: match[1],
          type: "general"
        });
        this.general_channel.received = this.handle_data;
      }

      if (
        this.role_channel === null ||
        JSON.parse(this.role_channel.identifier).room !== match[1]
      ) {
        if (this.role_channel !== null)
          consumer.subscriptions.remove(this.role_channel);
        this.role_channel = consumer.subscriptions.create({
          channel: "CourseChannel",
          room: match[1],
          type: "role"
        });
        this.role_channel.received = this.handle_data;
      }
    }
  }
});