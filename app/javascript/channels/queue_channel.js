import consumer from "./consumer";
import queryClient from "../src/utilities/queryClientFile";

consumer.subscriptions.create("QueueChannel", {
  connected() {
    this.update_course_channel = this.update_course_channel.bind(this);
    this.current_channel = null;

    document.addEventListener("turbo:load", this.update_course_channel);

    this.update_course_channel();
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  async received(data) {
    window.dispatchEvent(
      new CustomEvent("page:invalidate", { detail: data.invalidate })
    );
    await queryClient.invalidateQueries(data.invalidate);

    await queryClient.refetchQueries(data.invalidate);
  },

  update_course_channel() {
    const exp = /courses\/(\d+)/;

    const match = location.pathname.match(exp);

    if (match) {
      const room_jsons = consumer.subscriptions.subscriptions.map(
        (v) => JSON.parse(v.identifier).room
      );

      if (!this.current_channel) {
        this.current_channel = {
          general: consumer.subscriptions.create({
            channel: "QueueChannel",
            room: `${match[1]}`,
            type: "general",
          }),
          role: consumer.subscriptions.create({
            channel: "QueueChannel",
            room: `${match[1]}`,
            type: "role",
          }),
        };

        this.current_channel.general.received = async (data) => {
          if (process.env.NODE_ENV === "development") {
            console.log("invalidatinggeneral", data.invalidate);
          }

          window.dispatchEvent(
            new CustomEvent("page:invalidate", { detail: data.invalidate })
          );
          //Turbo.visit(window.location.toString(), { action: 'replace' })
          await queryClient.invalidateQueries(data.invalidate);

          await queryClient.refetchQueries(data.invalidate);
        };
        this.current_channel.role.received = async (data) => {
          if (process.env.NODE_ENV === "development") {
            console.log("invalidatingtas", data.invalidate);
          }

          window.dispatchEvent(
            new CustomEvent("page:invalidate", { detail: data.invalidate })
          );
          //Turbo.visit(window.location.toString(), { action: 'replace' })
          await queryClient.invalidateQueries(data.invalidate);

          await queryClient.refetchQueries(data.invalidate);
        };
      } else if (room_jsons.includes(`${match[1]}`)) {
      } else {
        consumer.subscriptions.remove(this.current_channel.general);
        consumer.subscriptions.remove(this.current_channel.role);

        this.current_channel = {
          general: consumer.subscriptions.create({
            channel: "QueueChannel",
            room: `${match[1]}`,
            type: "general",
          }),
          role: consumer.subscriptions.create({
            channel: "QueueChannel",
            room: `${match[1]}`,
            type: "role",
          }),
        };

        this.current_channel.general.received = async (data) => {
          if (process.env.NODE_ENV === "development") {
            console.log("invalidatinggeneral", data.invalidate);
          }

          window.dispatchEvent(
            new CustomEvent("page:invalidate", { detail: data.invalidate })
          );
          //Turbo.visit(window.location.toString(), { action: 'replace' })
          await queryClient.invalidateQueries(data.invalidate);

          await queryClient.refetchQueries(data.invalidate);
        };
        this.current_channel.role.received = async (data) => {
          if (process.env.NODE_ENV === "development") {
            console.log("invalidatingtas", data.invalidate);
          }

          window.dispatchEvent(
            new CustomEvent("page:invalidate", { detail: data.invalidate })
          );

          //Turbo.visit(window.location.toString(), { action: 'replace' })
          await queryClient.invalidateQueries(data.invalidate);

          await queryClient.refetchQueries(data.invalidate);
        };
      }
    }

    //console.log(consumer.subscriptions.subscriptions)
  },
});
