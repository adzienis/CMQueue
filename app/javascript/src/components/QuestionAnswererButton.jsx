import React, { useState } from "react";
import useWrappedMutation from "../hooks/useWrappedMutation";
import { useQuery } from "react-query";
import useOneShot from "../hooks/useOneShot";
import DelayedSpinner from "./DelayedSpinner";

export default (props) => {
  const { userId, courseId, enrollmentId } = props;

  const [loading, setLoading] = useState(false);

  const one = useOneShot(() => Turbo.visit(`/courses/${courseId}/answer`));

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
        if (d) {
          one();
        }
      },
    }
  );

  const { data: questions, isLoading: questionsLoading } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "questions",
    "?",
    `state=["unresolved"]`,
  ]);

  const { mutate: mutateAsync, isLoading: answerLoading } = useWrappedMutation(
    () => ({
      state: "resolving",
      enrollment_id: enrollmentId,
    }),
    `/api/courses/${courseId}/handle_question`,
    {},
    {
      onSuccess: async (d) => {
        setLoading(true);
        if (d) {
          await window.queryClient.prefetchQuery([
            "courses",
            parseInt(courseId, 10),
            "topQuestion",
            "?",
            `user_id=${userId}`,
          ]);
        }
      },
    }
  );

  return (
    <button
      onClick={(e) => {
        try {
          mutateAsync();
        } catch (e) {}
      }}
      disabled={!questions?.length}
      className={`btn queue-button mr-3 w-100 btn-${
        questions?.length > 0
          ? "success"
          : questionsLoading && !answerLoading
          ? "secondary"
          : "danger"
      }`}
    >
      <DelayedSpinner loading={answerLoading}>Answer a Question</DelayedSpinner>
    </button>
  );
};
