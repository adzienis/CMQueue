import React, { useMemo } from "react";
import { useInfiniteQuery, useQuery } from "react-query";
import QuestionCard from "./QuestionCard";
import useLocalStorage from "../hooks/useLocalStorage";

export default (props) => {
  const { courseId, userId, enrollmentId } = props;

  const { data: tags } = useQuery(["courses", parseInt(courseId, 10), "tags"]);

  const [selectedTags, setSelectedTags] = useLocalStorage(
    ["courses", parseInt(courseId, 10), "selectedTags"],
    []
  );

  const { data, fetchNextPage, hasNextPage } = useInfiniteQuery(
    ["courses", parseInt(courseId, 10), "paginatedQuestions"],
    ({ pageParam = -1 }) => {
      return fetch(
        `/api/courses/${courseId}/questions?cursor=${pageParam}&` +
          `state=["frozen", "unresolved"]&course_id=${courseId}&tags=${selectedTags.map(
            (v) => v.id
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
    }
  );

  const flattenedQuestions = useMemo(() => {
    return data?.pages.map((v) => v.data).flat();
  }, [data]);

  return (
    <div>
      <ul className="nav nav-pills nav-justified mb-3">
        {tags?.map((tag) => (
          <li className="nav-item">
            <a
              onClick={(e) => {
                e.preventDefault();

                if (
                  selectedTags.find(
                    (selectedTag) => selectedTag.name === tag.name
                  )
                ) {
                  setSelectedTags(
                    selectedTags.filter((v) => v.name !== tag.name)
                  );
                } else {
                  setSelectedTags([...selectedTags, tag]);
                }
              }}
              className={`nav-link ${
                selectedTags.find(
                  (selectedTag) => selectedTag.name === tag.name
                )
                  ? "active"
                  : ""
              }`}
              aria-current="page"
              href="#"
            >
              {tag.name}
            </a>
          </li>
        ))}
      </ul>
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
