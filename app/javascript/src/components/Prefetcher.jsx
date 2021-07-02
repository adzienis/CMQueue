// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, { useEffect } from "react";
import ReactDOM from "react-dom";
import { QueryClientProvider, useQuery, useQueryClient } from "react-query";

const Component = (props) => {
  const { userId } = props;
  const queryClient = useQueryClient();

  const { data: studentCourses } = useQuery(
    ["users", parseInt(userId, 10), "enrollments", "?", "role=student"],
    {
      placeholderData: [],
    }
  );
  const { data: taCourses } = useQuery(
    ["users", parseInt(userId, 10), "enrollments", "?", "role=ta"],
    {
      placeholderData: [],
    }
  );
  const { data: instructorCourses } = useQuery(
    ["users", parseInt(userId, 10), "enrollments", "?", "role=instructor"],
    {
      placeholderData: [],
    }
  );

  useEffect(() => {
    studentCourses.forEach((v) => {
      queryClient.prefetchQuery(["courses", parseInt(v.id, 10), "open_status"]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.id, 10),
        "questions",
        "count",
        "?",
        'state=["unresolved", "frozen"]',
      ]);
      queryClient.prefetchQuery(["courses", parseInt(v.id, 10), "activeTAs"]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.id, 10),
        "questions",
        "?",
        `user_id=${userId}`,
        'state=["unresolved", "frozen", "resolving"]',
      ]);
    });
  }, [studentCourses]);

  useEffect(() => {
    taCourses.forEach((v) => {
      queryClient.prefetchQuery(["courses", parseInt(v.id, 10), "open_status"]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.id, 10),
        "questions",
        "?",
        `state=["unresolved"]`,
      ]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.id, 10),
        "questions",
        "count",
        "?",
        'state=["unresolved", "frozen"]',
      ]);
      queryClient.prefetchQuery(["courses", parseInt(v.id, 10), "activeTAs"]);
      queryClient.prefetchInfiniteQuery(
        ["courses", parseInt(v.id, 10), "paginatedQuestions"],
        ({ pageParam = -1 }) => {
          return fetch(
            `/api/courses/${v.id}/questions?cursor=${pageParam}&` +
              `state=["frozen", "unresolved"]&course_id=${v.id}`,
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
        }
      );
    });
  }, [taCourses]);

  useEffect(() => {
    instructorCourses.forEach((v) => {
      queryClient.prefetchQuery(["courses", parseInt(v.id, 10), "open_status"]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.id, 10),
        "questions",
        "?",
        `state=["unresolved"]`,
      ]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.id, 10),
        "questions",
        "count",
        "?",
        'state=["unresolved", "frozen"]',
      ]);
      queryClient.prefetchQuery(["courses", parseInt(v.id, 10), "activeTAs"]);
      queryClient.prefetchInfiniteQuery(
        ["courses", parseInt(v.id, 10), "paginatedQuestions"],
        ({ pageParam = -1 }) => {
          return fetch(
            `/api/courses/${v.id}/questions?cursor=${pageParam}&` +
              `state=["frozen", "unresolved"]&course_id=${v.id}`,
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
        }
      );
    });
  }, [instructorCourses]);

  return null;
};

// Render component with data
document.addEventListener("turbo:load", (e) => {
  const node = document.querySelectorAll("#prefetcher");
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
