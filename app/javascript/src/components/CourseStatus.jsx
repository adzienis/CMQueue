import React, { useLayoutEffect } from "react";
import { useQuery } from "react-query";

export default (props) => {
  const { courseId } = props;

  const { data: count } = useQuery([
    "questions",
    "?",
    `course_id=${courseId}`,
    "agg=count",
    'state=["unresolved", "frozen"]',
  ]);

  useLayoutEffect(() => {
    if (typeof count !== "undefined") {
      if (count === 1) {
        document.title = `${count} question`;
      } else {
        document.title = `${count} questions`;
      }
    }
  }, [count]);

  return null;
};
