import React from "react";
import useWrappedMutation from "./useWrappedMutation";
import { useQuery } from "react-query";
import QuestionHistory from "./QuestionHistory";
import DelayedSpinner from "./DelayedSpinner";

export default (props) => {
  const { courseId, userId, question , enrollmentId } = props;

  const state = question?.question_state.state;

  const { mutateAsync: unfreeze, isLoading: frozenLoading } =
    useWrappedMutation(
      () => ({
        question_state: {
          state: "unresolved",
          question_id: question.id,
          enrollment_id: enrollmentId
        },
      }),
      "/question_states"
    );

  let statusText = "";
  let statusColor = "black";

  if (state === "frozen") {
    statusText = "Frozen since ";
    statusColor = "#2185D0";
  } else if (state === "unresolved") {
    statusText = "Waiting since ";
  } else if (state === "resolved") {
    statusText = "Resolved at ";
  } else if (state === "kicked") {
    statusText = "Kicked at ";
  }

  return (
    <div
      style={{ border: state === "frozen" ? "2px solid #2185D0" : "" }}
      className="card mb-3 shadow-sm"
    >
      <div className="position-absolute" style={{ top: "-15px", left: "0px" }}>
        {
          state === "frozen" ?
            <span className="badge me-1" style={{ backgroundColor: "#2185D0"}}>
              Frozen
            </span>
              : null
        }
        {question?.tags.map((v) => (
          <span className="badge bg-danger me-1">
            {v.name}
          </span>
        ))}
      </div>
      <div className="card-body">
        <div className="card-title">
          {question?.user ? (
            <>
              <b>{question?.user?.given_name}</b>
              <br />
            </>
          ) : null}
          <div style={{ color: "#2185D0" }}>
            {state !== "unresolved" ? (
              <span>
                {statusText}
                <b>{new Date(question.updated_at).toLocaleTimeString()}</b>
              </span>
            ) : (
              <span>
                {statusText}
                <b>{new Date(question.created_at).toLocaleTimeString()}</b>
              </span>
            )}
          </div>
        </div>
        <div className="card-text elipsis">{question.description}</div>
      </div>
      <div className="card-footer">
        <div className="d-flex flex-wrap">
          {state === "frozen" ? (
            <div className="me-2 mb-2">
              <button
                className="btn btn-primary"
                style={{ backgroundColor: "rgb(33, 133, 208)" }}
                onClick={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  unfreeze();
                }}
              >
                <DelayedSpinner loading={frozenLoading} small>
                  Unfreeze
                </DelayedSpinner>
              </button>
            </div>
          ) : null}
          <div className="d-flex align-items-center me-2 mb-2">
            <a
              href={`/courses/${courseId}/questions/${question?.id}`}
              className="text-decoration-none"
              style={{ color: "inherit" }}
            >
              <button className="btn btn-secondary">
                <i className="fas fa-info-circle fa-lg me-2"></i>
                <span>
                More info
                </span>
              </button>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
};
