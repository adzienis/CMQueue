import React, {useEffect, useRef} from 'react';
import {QueryClientProvider, useQuery} from "react-query";
import ReactDOM from "react-dom";
import useWrappedMutation from "./useWrappedMutation";


const Component = props => {

    const {userId} = props;

    const ref = useRef();

    const {data: notifications} = useQuery(['users', parseInt(userId, 10), 'unread_notifications'])

    const {mutate: markAsRead} = useWrappedMutation(
        (notification_id) => ({
            url: `/api/notifications/${notification_id}/mark_as_read`
        })
    );

    const {data: settings} = useQuery(['settings', '?', `user_id=${userId}`], {
        onSuccess: d => {
            window.settings = d
        }
    })

    if(settings?.find(v => v.key === "Site Notifications").value === "false") return null;


    return (
        <div className="toast-container position-fixed top-0 end-0 mt-3 me-3">
            {notifications?.map(v => {

                let title = null;
                let body = null;

                switch (v.params.type) {
                    case "QuestionState":
                        title = v.params.title;
                        body = v.params.why;
                        break;
                }

                return (
                    <div key={v.id} className="toast show" role="alert" aria-live="assertive" aria-atomic="true">
                        <div className="toast-header">
                            <strong className="me-auto">{title}</strong>
                            <small className="text-muted">{new Date(v.created_at).toLocaleTimeString()}</small>
                            <button
                                type="button"
                                className="btn-close"
                                data-bs-dismiss="toast"
                                aria-label="Close"
                                onClick={e => {
                                    try {
                                        markAsRead(v.id)
                                    } catch (e) {

                                    }
                                }}
                            ></button>
                        </div>
                        <div className="toast-body">
                            {body}
                        </div>
                    </div>
                )


            })}
        </div>
    );
}

document.addEventListener("turbo:load", (e) => {
    const node = document.querySelectorAll("#notification-feed");
    if (node.length > 0) {
        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute("data"));

            ReactDOM.render(
                <QueryClientProvider client={window.queryClient} contextSharing>
                    <Component {...data} />
                </QueryClientProvider>, v
            );
        });
    }
});
