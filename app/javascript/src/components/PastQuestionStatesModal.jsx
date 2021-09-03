import React from "react";
import { useQuery } from "react-query";
import RenderedAtBody from "../RenderedAtBody";

export default (props) => {
  const { question } = props;

  const { data: question_states } = useQuery([
    "questions",
    question?.id,
    "question_states",
  ]);

  return (
    <>
      <div
        tabIndex="-1"
        className="d-flex"
        data-bs-toggle="modal"
        data-bs-target={`#question_${question?.id}`}
      >
        {question_states ? (
          <div>
            <span className="badge bg-danger me-1">
              {question_states.length}
            </span>
          </div>
        ) : null}
        {props.children}
      </div>

      <RenderedAtBody>
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
      </RenderedAtBody>
    </>
  );
};
