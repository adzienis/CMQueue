import React, { useMemo } from "react";
import { useInfiniteQuery, useQuery } from "react-query";
import QuestionCard from "./QuestionCard";
import useLocalStorage from "../hooks/useLocalStorage";
import Select from "react-select";

export default (props) => {
  const { courseId, userId, enrollmentId } = props;

  const { data: tags } = useQuery(["courses", parseInt(courseId, 10), "tags"]);

  const [selectedTags, setSelectedTags] = useLocalStorage(
    ["courses", parseInt(courseId, 10), "selectedTags"],
    []
  );

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

  return (
    <div>
      <div className="mb-4">
        <label className="fw-bold">Filter Questions by Tag</label>
        <Select
          placeholder="Select a Tag to Filter Questions"
          isMulti
          onChange={(data) => {
            const mapped = data.map((tag) =>
              tags.find((otherTag) => otherTag.id === tag.value)
            );

            setSelectedTags(mapped);
          }}
          value={selectedTags.map((tag) => ({
            value: tag.id,
            label: tag.name,
          }))}
          options={tags?.map((tag) => ({
            value: tag.id,
            label: tag.name,
          }))}
        />
      </div>
      <div className="mb-4">
        {flattenedQuestions?.length > 0 ? (
          flattenedQuestions?.map((v) => (
            <QuestionCard
              enrollmentId={enrollmentId}
              key={v.id}
              question={v}
              userId={userId}
              courseId={courseId}
            />
          ))
        ) : (
          <div className="alert alert-warning border">
            <span>No Questions</span>
          </div>
        )}
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
