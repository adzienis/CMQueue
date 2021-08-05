import React, { useEffect, useState } from "react";
import { useQuery } from "react-query";

/**
 * Renders the total amount of time spent "resolving" the question.
 * Updates every second.
 *
 *
 * @param props
 * @returns {JSX.Element|null}
 */
export default (props) => {
  const { questionId } = props;

  const [time, setTime] = useState();

  const { data: question } = useQuery(["questions", parseInt(questionId, 10)]);

  useEffect(() => {
    if (question) {
      const startedAnswering = new Date(question.question_state.created_at);
      const minutesAnswering = Math.floor(
        (new Date() - startedAnswering) / 1000
      );

      setTime(minutesAnswering);

      const timeout = setInterval(() => {
        const startedAnswering = new Date(question.question_state.created_at);
        const minutesAnswering = Math.floor(
          (new Date() - startedAnswering) / 1000
        );

        setTime(minutesAnswering);
      }, 1000);

      return () => clearTimeout(timeout);
    }
    return () => null;
  }, [question]);

  if (
    !question ||
    question.question_state.state !== "resolving" ||
    typeof time === "undefined"
  ) {
    return null;
  }

  return (
    <div className="d-flex justify-content-center align-items-center flex-column">
      <h2>
        {Math.floor(time / 60)}:{(time % 60).toString().padStart(2, "0")}
      </h2>
      <h5 className="text-black-50">
        <small>Time Spent Answering</small>
      </h5>
    </div>
  );
};
