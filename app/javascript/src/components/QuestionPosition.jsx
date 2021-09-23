import React from "react";
import { useQuery } from "react-query";
import QueueInfoItem from "./QueueInfoItem";

export default (props) => {
  const { question, courseId } = props;

  const { data: position, isLoading: positionLoading } = useQuery(
    [
      "questions",
      "position",
      "?",
      `course_id=${courseId}`,
      `question_id=${question?.id}`,
      `state=["unresolved", "frozen"]`,
    ],
    {
      enabled: !!question,
    }
  );

  return (
    <QueueInfoItem
      title={"Your Position on Queue"}
      loading={positionLoading}
      icon={
        <div className="me-3 d-flex justify-content-center align-items-center">
          <i className="fas fa-map-marker-alt fa-2x" />
        </div>
      }
      value={
        position === 0
          ? "Next"
          : typeof position === "undefined" || position === null
          ? "N/A"
          : position
      }
    />
  );
};
