import consumer from "./consumer";
import queryClient from "../src/utilities/queryClientFile";

export default consumer.subscriptions.create("Noticed::NotificationChannel", {
    connected() {
        // Called when the subscription is ready for use on the server

    },

    disconnected() {
        // Called when the subscription has been terminated by the server
    },

    async received(data) {

        console.log('window sett', window.settings, data)

        if (("Notification" in window) && Notification.permission === "granted" && window.settings?.find(v => v.key === "Desktop_Notifications")?.value === "true") {
            switch (data.params?.type) {
                case "QuestionState":
                    var notification = new Notification(`CMQueue: ${data.params.title}`, {
                        body: data.params.why
                    });
                    break;
            }
        }

        if(data.invalidate) {
            await queryClient.invalidateQueries(data.invalidate);

            await queryClient.refetchQueries(data.invalidate);
        }
    },
});
