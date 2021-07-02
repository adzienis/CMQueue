import React, {useCallback, useRef, useState} from "react";
import useWrappedMutation from "./useWrappedMutation";
import { useQuery } from "react-query";
import useOneShot from "../hooks/useOneShot";



export default (props) => {
  const { userId, courseId, enrollmentId } = props;

  const [loading, setLoading] = useState(false);



  const one = useOneShot(() => Turbo.visit(`/courses/${courseId}/answer`))

  const { data: topQuestion } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "topQuestion",
    "?",
    `user_id=${userId}`,
  ], {
    onSuccess: async (d) => {
      console.log(d, 'here')
      if(d) {
        one()
      }
    }
  });

  const { data: questions, isLoading: questionsLoading } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "questions",
    "?",
    `state=["unresolved"]`,
  ]);

  const { mutate: mutateAsync, isLoading: answerLoading } = useWrappedMutation(
    () => ({
      answer: {
        state: "resolving",
        enrollment_id: enrollmentId,
      },
    }),
    `/api/courses/${courseId}/answer`,
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
      {(topQuestion || questionsLoading) ? (
        <div className="spinner-border" role="status">
          <span className="visually-hidden">Loading...</span>
        </div>
      ) : (
        <span> Answer a Question </span>
      )}
    </button>
  );
};
