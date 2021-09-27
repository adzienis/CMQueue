import React, { useEffect, useMemo } from "react";
import { useQuery } from "react-query";
import QueueInfoItem from "./QueueInfoItem";
import TALog from "./TALog";
import QuestionPosition from "./QuestionPosition";
import useLocalStorage from "../hooks/useLocalStorage";

export default (props) => {
  const { courseId, userId, enrollment } = props;

  const { data: d } = useQuery(["answer_time", "?", `course_id=${courseId}`]);

  const [panelOpened, setPanelOpened] = useLocalStorage(
    ["courses", parseInt(courseId, 10), "panelOpened"],
    true
  );

  const {
    data: [question],
  } = useQuery(
    [
      "courses",
      parseInt(courseId, 10),
      "questions",
      "?",
      `user_id=${userId}`,
      'state=["unresolved", "frozen", "resolving"]',
    ],
    {
      placeholderData: [null],
    }
  );

  const { data: openStatus, isLoading: openLoading } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "open",
  ]);

  const { data: count, isLoading: countLoading } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "questions",
    "?",
    "agg=count",
    `state=${JSON.stringify(["unresolved", "frozen"])}`,
  ]);

  const { data: activeTas, isLoading: activeLoading } = useQuery([
    `courses`,
    parseInt(courseId, 10),
    "recent_activity",
  ]);

  const accordionState = useMemo(() => {
    return panelOpened;
  }, []);

  return (
    <div className="accordion mt-3 mb-4 w-100">
      <div className="accordion-item">
        <h2 className="accordion-header d-flex">
          <button
            className="accordion-button"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#info-collapse"
            onClick={(e) => setPanelOpened(!panelOpened)}
          >
            <b>Queue Information</b>
          </button>
        </h2>
        <div
          id="info-collapse"
          className={`accordion-collapse collapse ${
            accordionState ? "show" : ""
          }`}
        >
          <div className="accordion-body">
            <div
              className="mb-2"
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
                gridGap: "10px",
              }}
            >
              <QueueInfoItem
                title={"Queue Status"}
                icon={
                  <div className="me-3 d-flex justify-content-center align-items-center">
                    <i className="fas fa-question fa-2x" />
                  </div>
                }
                loading={openLoading}
                value={
                  openStatus ? (
                    <span className="text-success"> Open </span>
                  ) : (
                    <span className="text-danger"> Closed </span>
                  )
                }
              />
              <QueueInfoItem
                info="Total number of questions that haven't been answered"
                title={"Unresolved Questions"}
                icon={
                  <div className="me-3 d-flex justify-content-center align-items-center">
                    <i className="fas fa-question fa-2x" />
                  </div>
                }
                loading={countLoading}
                value={count}
              />
              {enrollment?.role.name === "student" && question ? (
                <QuestionPosition question={question} courseId={courseId} />
              ) : null}
            </div>
            <QueueInfoItem
              info="Shows which TA's have had activity within the past 15 minutes."
              title={"Active TA's"}
              loading={activeLoading}
              icon={
                <div className="me-3 d-flex justify-content-center align-items-center">
                  <i className="fas fa-users fa-3x" />
                </div>
              }
              value={activeTas?.map((v) => v.given_name).join(", ")}
              footer={
                enrollment?.role.name !== "student" ? (
                  <div className="accordion" id="accordion-ta-log">
                    <div className="accordion-item">
                      <h2 className="accordion-header">
                        <button
                          className="accordion-button collapsed"
                          type="button"
                          data-bs-toggle="collapse"
                          data-bs-target="#collapse-ta-log"
                        >
                          <b>TA Log</b>
                        </button>
                      </h2>
                      <div
                        id="collapse-ta-log"
                        className="accordion-collapse collapse"
                        data-bs-parent="#accordion-ta-log"
                      >
                        <div className="accordion-body p-0">
                          <TALog height={300} courseId={courseId} />
                        </div>
                      </div>
                    </div>
                  </div>
                ) : null
              }
            />
          </div>
        </div>
      </div>
    </div>
  );
};
