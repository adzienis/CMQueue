import React, { useContext, useMemo } from "react";
import { useInfiniteQuery, useQuery } from "react-query";
import QuestionCard from "./QuestionCard";
import useLocalStorage from "../hooks/useLocalStorage";
import Select from "react-select";
import UserContext from "../context/UserContext";

export default (props) => {
  const { courseId, userId, enrollmentId } = props;

  const { data: tags } = useQuery(["courses", parseInt(courseId, 10), "tags"]);

  const { selectedTags, setSelectedTags } = useContext(UserContext);

  const { data: count, isLoading: countLoading } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "questions",
    "?",
    "agg=count",
    `state=${JSON.stringify(["unresolved", "frozen"])}`,
  ]);

  const {
    data,
    fetchNextPage,
    hasNextPage,
    isLoading: questionsLoading,
  } = useInfiniteQuery(
    [
      "courses",
      parseInt(courseId, 10),
      "paginatedQuestions",
      "?",
      `tags=${JSON.stringify(selectedTags.map((v) => v?.id))}`,
    ],
    ({ pageParam = -1 }) => {
      return fetch(
        `/api/courses/${courseId}/questions?cursor=${pageParam}&` +
          `state=["frozen", "unresolved"]&course_id=${courseId}&tags=${JSON.stringify(
            selectedTags.map((v) => v?.id)
          )}`,
        {
          headers: {
            Accept: "application/json",
          },
        }
      )
        .then((resp) => resp.json())
        .then((json) => {
          return {
            cursor: json.cursor?.id,
            data: json.data,
          };
        });
    },
    {
      getNextPageParam: (lastPage, pages) => {
        return lastPage.cursor;
      },
      keepPreviousData: true,
    }
  );

  const flattenedQuestions = useMemo(() => {
    return data?.pages.map((v) => v.data).flat();
  }, [data]);

  let questions = null;

  if (!questionsLoading) {
    questions = flattenedQuestions?.map((v) => (
      <QuestionCard
        enrollmentId={enrollmentId}
        key={v.id}
        question={v}
        userId={userId}
        courseId={courseId}
      />
    ));

    if (count === 0) {
      questions = (
        <div className="alert alert-warning border">
          No questions left on the queue.
        </div>
      );
    } else if (questions.length === 0) {
      questions = (
        <div className="alert alert-warning border">
          No questions with these tags, but there are still <b> {count} </b>{" "}
          questions left!
        </div>
      );
    }
  } else {
    questions = (
      <div className="card card-body w-100 d-flex justify-content-center align-items-center">
        <div className="spinner-border" role="status">
          <span className="visually-hidden">Loading...</span>
        </div>
      </div>
    );
  }

  return (
    <div>
      <div className="mb-4">
        {questions}
        <div className="mt-4">
          <button
            className="btn btn-primary"
            onClick={async () => {
              await fetchNextPage();
            }}
            disabled={!hasNextPage}
          >
            Load More Questions
          </button>
        </div>
      </div>
    </div>
  );
};
