import consumer from "./consumer";

async function handle_data(data) {
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
}

class CourseChannelManager {
    constructor() {
        this.update_course_channel = this.update_course_channel.bind(this);
        this.general_channel = null;
        this.role_channel = null;

        document.addEventListener("turbo:load", this.update_course_channel);

        consumer.subscriptions.create({
            channel: "CourseChannel"
        }, {
            received(data) {
                this.handle_data(data);
            },
            handle_data
        });

        this.update_course_channel();
    }

    unsubscribe_from_channel(channel_name) {
        if (this[channel_name] === null) return null

        consumer.subscriptions.remove(this[channel_name]);
        this[channel_name] = null;
    }

    update_course_channel() {
        const exp = /courses\/(\d+)/;

        const match = location.pathname.match(exp);

        if (match) {
            console.log(location.pathname, consumer.subscriptions.subscriptions)
            if (
                this.general_channel === null ||
                JSON.parse(this.general_channel.identifier).room !== match[1]
            ) {
                this.unsubscribe_from_channel("general_channel")


                this.general_channel = consumer.subscriptions.create({
                    channel: "CourseChannel",
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
                this.unsubscribe_from_channel("role_channel")

                this.role_channel = consumer.subscriptions.create({
                    channel: "CourseChannel",
                    room: match[1],
                    type: "role"

                }, {
                    received(data) {
                        this.handle_data(data);
                    },
                    handle_data
                });
            }
        } else {
            this.unsubscribe_from_channel("general_channel")
            this.unsubscribe_from_channel("role_channel")
        }
    }
}

new CourseChannelManager()