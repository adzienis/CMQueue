import React, { useMemo } from "react";
import ReactDOM from "react-dom";
import { QueryClientProvider, useInfiniteQuery } from "react-query";
import QuestionCard from "./QuestionCard";

const Component = (props) => {
  const { courseId, userId, enrollmentId } = props;

  const { data, fetchNextPage, hasNextPage } = useInfiniteQuery(
    ["courses", parseInt(courseId, 10), "paginatedQuestions"],
    ({ pageParam = -1 }) => {
      return fetch(
        `/api/courses/${courseId}/questions?cursor=${pageParam}&` +
          `state=["frozen", "unresolved"]&course_id=${courseId}`,
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

  console.log(data)

  return (
    <div>
      <div className="mb-4">
        <h1 className="mb-3">Questions</h1>
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

document.addEventListener("turbo:load", (e) => {
  const node = document.querySelectorAll("#ta-queue-view");
  if (node.length > 0) {
    node.forEach((v) => {
      const data = JSON.parse(v.getAttribute("data"));

      ReactDOM.render(
        <QueryClientProvider client={window.queryClient} contextSharing>
          <Component {...data} />
        </QueryClientProvider>,
        v
      );
    });
  }
});
