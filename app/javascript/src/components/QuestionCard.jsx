import React from "react";
import useWrappedMutation from "../hooks/useWrappedMutation";
import QuestionHistory from "./QuestionHistory";
import DelayedSpinner from "./DelayedSpinner";
import {useQuery} from "react-query";


export default (props) => {
    const {courseId, userId, question, enrollmentId} = props;

    const state = question?.question_state.state;

    const {data: topQuestion} = useQuery([
        "courses",
        parseInt(courseId, 10),
        "topQuestion",
        "?",
        `user_id=${userId}`,
    ]);

    const {mutateAsync: unfreeze, isLoading: frozenLoading} =
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

    const {mutate: answerQuestion, isLoading: answerLoading} = useWrappedMutation(
        () => ({
            state: "resolving",
            enrollment_id: enrollmentId,
        }),
        `/api/questions/${question?.id}/handle_question`
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
            className={`card mb-3 shadow-sm ${state === "frozen" ? "frozen-card" : ""}`}
        >
            <div className="position-absolute" style={{top: "-15px", left: "0px"}}>
                {
                    state === "frozen" ?
                        <span className="badge me-1" style={{backgroundColor: "var(--frozen)"}}>
              Frozen
            </span>
                        : null
                }
                {question?.tags.map((v) => (
                    <span key={v.name} className="badge bg-danger me-1">
            {v.name}
          </span>
                ))}
            </div>
            <div className="card-body">
                <div className="card-title">
                    {question?.user ? (
                        <>
                            <b>{question?.user?.given_name}</b>
                            <br/>
                        </>
                    ) : null}
                    <div style={{color: "var(--frozen)"}}>
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
                <div className="card-footer-buttons">
                    {state === "frozen" ? (
                        <button
                            className="btn btn-primary"
                            style={{backgroundColor: "rgb(33, 133, 208)"}}
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
                    ) : null}
                    {
                        state === "unresolved" ? (
                            <button
                                className="btn btn-success"
                                onClick={e => {
                                    try {
                                        answerQuestion()
                                    } catch (e) {

                                    }
                                }}>
                                <DelayedSpinner loading={answerLoading} small>
                                    Answer
                                </DelayedSpinner>
                            </button>
                        ) : null
                    }

                    <a
                        href={`/courses/${courseId}/questions/${question?.id}`}
                        className="btn btn-secondary text-decoration-none"
                    >
                        More info
                    </a>
                    <QuestionHistory question={question}/>
                </div>
            </div>
        </div>
    );
};
