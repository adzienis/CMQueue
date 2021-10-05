import QuestionExplainer from "./QuestionExplainer";
import React, { useRef, useState } from "react";
import { useQuery } from "react-query";
import useWrappedMutation from "../hooks/useWrappedMutation";

import modal from "bootstrap/js/dist/modal";
import useOneShot from "../hooks/useOneShot";
import QuestionAnsweringTime from "./QuestionAnsweringTime";

export default (props) => {
  const { userId, courseId, enrollmentId } = props;
  const refq = useRef();

  const [openExplain, setOpenExplain] = useState(false);

  const one = useOneShot(() => Turbo.visit(`/courses/${courseId}/queue`));

  const { data: topQuestion } = useQuery(
    [
      "courses",
      parseInt(courseId, 10),
      "topQuestion",
      "?",
      `user_id=${userId}`,
    ],
    {
      onSuccess: async (d) => {
        if (!d) {
          one();
        }
      },
    }
  );

  const { mutateAsync: handleQuestion, isLoading: handleLoading } =
    useWrappedMutation(
      ({ state, description }) => ({
        state,
        enrollment_id: enrollmentId,
        question_id: topQuestion.id,
        description,
      }),
      `/questions/${topQuestion?.id}/handle`,
      {},
      {
        onSuccess: (d) => {
          if (d) {
          }
        },
      }
    );

  if (!topQuestion)
    return (
      <div className="card shadow" style={{ height: "600px" }}>
        <div className="card-body h-100">
          <div className="w-100 d-flex justify-content-center align-items-center h-100">
            <div className="spinner-border" role="status">
              <span className="visually-hidden">Loading...</span>
            </div>
          </div>
        </div>
      </div>
    );

  return (
    <>
      <QuestionExplainer
        question={topQuestion}
        userId={userId}
        callback={refq.current}
        open={openExplain}
        setOpen={setOpenExplain}
      />
      <div className="card mb-1">
        <div className="card-body">
          <QuestionAnsweringTime questionId={topQuestion.id} />
        </div>
      </div>
      <div className="card shadow mb-5" style={{ height: "600px" }}>
        <div className="card-body">
          <div className="card-title">
            <div className="d-flex">
              <h2>
                {`${topQuestion?.user?.given_name} ${topQuestion?.user?.family_name}`}
              </h2>
              <div className="flex-1" />
              <a href={`/courses/${courseId}/questions/${topQuestion?.id}`}>
                More info <i className="fas fa-info-circle fa-lg"></i>
              </a>
            </div>
          </div>
          <hr />
          <div>
            <div className="p-1">
              <div className="mb-2">
                <h4>
                  <b>Description</b>
                </h4>
                <span>{topQuestion?.description}</span>
              </div>
              <div className="mb-2">
                <h4>
                  <b>What Have They Tried?</b>
                </h4>
                <span>{topQuestion?.tried}</span>
              </div>
              <div className="mb-2">
                <h4>
                  <b>Zoom</b>
                </h4>
                <span>{topQuestion?.location}</span>
              </div>
              <div className="mb-2">
                <h4>
                  <b>Queues</b>
                </h4>
                <span>
                  {topQuestion?.tags?.map((v, i) => (
                    <a href={`/courses/${courseId}/tags/${v.id}`}>
                      <b>{v.name}</b>
                      {topQuestion?.tags?.length > 0 &&
                      i < topQuestion?.tags?.length - 1
                        ? ", "
                        : ""}
                    </a>
                  ))}
                </span>
              </div>
            </div>
          </div>
        </div>
        <div className="card-footer">
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))",
              rowGap: "5px",
              columnGap: "5px",
            }}
          >
            <button
              className="btn btn-success"
              onClick={() => {
                try {
                  handleQuestion({
                    state: "resolved",
                  });
                } catch (e) {}
              }}
            >
              Finish Resolving
            </button>
            <button
              className="btn btn-primary"
              onClick={() => {
                try {
                  const m = new modal(
                    document.getElementById("explanationModal"),
                    {}
                  );
                  m.show();
                  refq.current = async (description) =>
                    handleQuestion({
                      state: "frozen",
                      description,
                    });

                  setOpenExplain(true);
                } catch (e) {}
              }}
            >
              Freeze
            </button>
            <button
              className="btn btn-danger"
              onClick={() => {
                try {
                  const m = new modal(
                    document.getElementById("explanationModal"),
                    {}
                  );
                  m.show();

                  refq.current = async (description) =>
                    handleQuestion({
                      state: "kicked",
                      description,
                    });

                  setOpenExplain(true);
                } catch (e) {}
              }}
            >
              Kick
            </button>
            <button
              className="btn btn-secondary"
              onClick={() => {
                try {
                  handleQuestion({
                    state: "unresolved",
                  });
                } catch (e) {}
              }}
            >
              Put Back
            </button>
          </div>
        </div>
      </div>
    </>
  );
};
