import React from "react";
import { useQuery } from "react-query";
import TurboFrame from "./TurboFrame";

export default (props) => {
  const { question } = props;

  const { data: question_states } = useQuery([
    "questions",
    question?.id,
    "question_states",
  ]);
  const { data: previous_questions } = useQuery([
    "questions",
    question?.id,
    "previousQuestions",
  ]);

  return (
    <>
      <button
        type="button"
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
        }}
        className="btn btn-secondary position-relative"
        data-bs-toggle="modal"
        data-bs-target={`#question_${question?.id}`}
      >
        <span>Past Question States</span>

        {question_states ? (
          <div
            className="position-absolute"
            style={{ top: "-15px", left: "0px" }}
          >
            <span className="badge bg-danger me-1">
              {question_states.length}
            </span>
          </div>
        ) : null}
      </button>

      <div
        className="modal fade"
        id={`question_${question?.id}`}
        tabIndex="-1"
        aria-labelledby="historyModal"
        aria-hidden="true"
      >
        <div className="modal-dialog modal-dialog-centered modal-xl">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="historyModalLabel">
                {" "}
                Question History{" "}
              </h5>
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              />
            </div>
            <div className="modal-body">
              <turbo-frame
                id="container"
                src={`/questions/${question?.id}/question_states`}
              />
            </div>
          </div>
        </div>
      </div>

      <button
        type="button"
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
        }}
        className="btn btn-secondary position-relative"
        data-bs-toggle="modal"
        data-bs-target={`#question_history_${question?.id}`}
      >
        <span>Previous Questions</span>
        {previous_questions ? (
          <div
            className="position-absolute"
            style={{ top: "-15px", left: "0px" }}
          >
            <span className="badge bg-danger me-1">
              {previous_questions.length}
            </span>
          </div>
        ) : null}
      </button>

      <div
        className="modal fade"
        id={`question_history_${question?.id}`}
        tabIndex="-1"
        aria-labelledby="historyModal"
        aria-hidden="true"
      >
        <div className="modal-dialog modal-dialog-centered modal-xl">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="historyModalLabel">
                Question History
              </h5>
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              />
            </div>
            <div className="modal-body">
              <turbo-frame
                id="container"
                src={`/questions/${question?.id}/previousQuestions`}
              />
            </div>
          </div>
        </div>
      </div>
    </>
  );
};
