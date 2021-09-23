import React, { useEffect } from "react";
import { useQuery, useQueryClient } from "react-query";

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
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.role.resource_id, 10),
        "open",
      ]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.role.resource_id, 10),
        "questions",
        "?",
        `user_id=${userId}`,
        'state=["unresolved", "frozen", "resolving"]',
      ]);
    });
  }, [studentCourses]);

  useEffect(() => {
    taCourses.forEach((v) => {
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.role.resource_id, 10),
        "open",
      ]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.role.resource_id, 10),
        "questions",
        "?",
        `state=["unresolved"]`,
      ]);
      queryClient.prefetchInfiniteQuery(
        ["courses", parseInt(v.role.resource_id, 10), "paginatedQuestions"],
        ({ pageParam = -1 }) => {
          return fetch(
            `/api/courses/${v.id}/questions?cursor=${pageParam}&` +
              `state=["frozen", "unresolved"]&course_id=${v.role.resource_id}`,
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
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.role.resource_id, 10),
        "open",
      ]);
      queryClient.prefetchQuery([
        "courses",
        parseInt(v.role.resource_id, 10),
        "questions",
        "?",
        `state=["unresolved"]`,
      ]);
      queryClient.prefetchInfiniteQuery(
        ["courses", parseInt(v.role.resource_id, 10), "paginatedQuestions"],
        ({ pageParam = -1 }) => {
          return fetch(
            `/api/courses/${v.role.resource_id}/questions?cursor=${pageParam}&` +
              `state=["frozen", "unresolved"]&course_id=${v.role.resource_id}`,
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

  // Must do this to prevent infinite renderings because of the registerManager
  return <div className="d-none" />;
};
