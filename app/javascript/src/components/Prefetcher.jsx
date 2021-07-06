import React, { useEffect } from "react";
import ReactDOM from "react-dom";
import { QueryClientProvider, useQuery, useQueryClient } from "react-query";

export default (props) => {
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