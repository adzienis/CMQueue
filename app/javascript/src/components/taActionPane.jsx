// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

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
