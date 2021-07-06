
import React, { useMemo } from "react";
import ReactDOM from "react-dom";
import { QueryClientProvider, useInfiniteQuery } from "react-query";
import QuestionAnswerer from "./QuestionAnswererButton";
import QueueOpener from "./QueueOpener";

export default (props) => {
  const { courseId, userId, enrollmentId } = props;
  return (
    <div className="mb-4">
      <div className="d-flex">
        <div
          className="w-100"
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
            gridGap: "10px",
          }}
        >
          <QuestionAnswerer userId={userId} courseId={courseId} enrollmentId={enrollmentId} />
          <QueueOpener userId={userId} courseId={courseId} />
        </div>
      </div>
    </div>
  );
};
