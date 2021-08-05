import React, { useRef } from "react";
import { useQuery } from "react-query";
import useWrappedMutation from "../hooks/useWrappedMutation";

export default (props) => {
  const { userId } = props;

  const ref = useRef();

  const { data: notifications } = useQuery([
    "users",
    parseInt(userId, 10),
    "unread_notifications",
  ]);

  const { mutate: markAsRead } = useWrappedMutation((notification_id) => ({
    url: `/api/notifications/${notification_id}/mark_as_read`,
  }));

  const { data: settings } = useQuery(["settings", "?", `user_id=${userId}`], {
    onSuccess: (d) => {
      window.settings = d;
    },
  });

  if (!settings) return <div className="d-none" />;

  if (settings?.find((v) => v.key === "Site Notifications").value === "false")
    return <div className="d-none" />;

  return (
    <div className="toast-container position-fixed top-0 end-0 mt-3 me-3">
      {notifications?.length > 0 ? (
        <div
          className="toast show"
          role="alert"
          aria-live="assertive"
          aria-atomic="true"
        >
          <div className={`toast-header`}>
            <strong className="me-auto">Clear All Notifications</strong>
            <button
              type="button"
              className={`btn-close`}
              data-bs-dismiss="toast"
              aria-label="Close"
              onClick={(e) => {
                try {
                  notifications?.map((v) => markAsRead(v.id));
                } catch (e) {}
              }}
            />
          </div>
        </div>
      ) : null}
      {notifications?.map((v) => {
        let title = null;
        let body = null;
        let className = "";

        switch (v.params.type) {
          case "QuestionState":
            title = v.params.title;
            body = v.params.why;
            className = "bg-frozen text-light";
            break;
          case "Success":
            title = v.params.title;
            body = v.params.body;
            className = "bg-success text-white";
            break;
        }

        return (
          <div
            key={v.id}
            className="toast show"
            role="alert"
            aria-live="assertive"
            aria-atomic="true"
          >
            <div className={`toast-header ${className}`}>
              <strong className="me-auto">{title}</strong>
              <small
                className={
                  className.includes("text-light") ? "text-light" : "text-muted"
                }
              >
                {new Date(v.created_at).toLocaleTimeString()}
              </small>
              <button
                type="button"
                className={`btn-close ${
                  className.includes("text-light") ? "bg-light" : ""
                }`}
                data-bs-dismiss="toast"
                aria-label="Close"
                onClick={(e) => {
                  try {
                    markAsRead(v.id);
                  } catch (e) {}
                }}
              ></button>
            </div>
            <div className="toast-body">{body}</div>
          </div>
        );
      })}
    </div>
  );
};
