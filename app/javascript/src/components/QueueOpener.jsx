import React from "react";
import useWrappedMutation from "../hooks/useWrappedMutation";
import { useQuery } from "react-query";
import DelayedSpinner from "./DelayedSpinner";

export default (props) => {
  const { userId, courseId } = props;

  const { data: openStatus, isLoading: openLoading } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "open",
  ]);

  const { mutateAsync, isLoading: queueLoading } = useWrappedMutation(
    () => ({
      status: !openStatus,
    }),
    `/api/courses/${courseId}/open`
  );

  return (
    <button
      className={`btn btn-primary queue-button w-100 btn-${
        openStatus
          ? "success"
          : openLoading && !queueLoading
          ? "secondary"
          : "danger"
      }`}
      onClick={(e) => {
        try {
          mutateAsync();
        } catch (e) {}
      }}
    >
      {openLoading ? (
        <div className="spinner-border" role="status">
          <span className="visually-hidden">Loading...</span>
        </div>
      ) : (
        <DelayedSpinner loading={queueLoading || openLoading}>
          <span>{openStatus ? "Close Queue" : "Open Queue"}</span>
        </DelayedSpinner>
      )}
    </button>
  );
};

// variant={}
