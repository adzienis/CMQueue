import React, { useContext } from "react";
import useWrappedMutation from "../hooks/useWrappedMutation";
import { useQuery } from "react-query";
import useOneShot from "../hooks/useOneShot";
import DelayedSpinner from "./DelayedSpinner";
import UserContext from "../context/UserContext";

export default (props) => {
  const { userId, courseId, enrollmentId } = props;

  const one = useOneShot(() => Turbo.visit(`/courses/${courseId}/answer`));

  const { selectedTags, setSelectedTags } = useContext(UserContext);

  const { data: topQuestion } = useQuery(
    [
      "api",
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
    `tags=${JSON.stringify(selectedTags.map((v) => v?.id))}`,
  ]);

  const { mutate: mutateAsync, isLoading: answerLoading } = useWrappedMutation(
    () => ({
      state: "resolving",
      enrollment_id: enrollmentId,
    }),
    `/api/courses/${courseId}/handle_question?tags=${JSON.stringify(
      selectedTags.map((tag) => tag.id)
    )}`,
    {},
    {
      onSuccess: async (d) => {
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
