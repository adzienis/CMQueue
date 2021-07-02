// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from "react";
import ReactDOM from "react-dom";
import { QueryClientProvider, useQuery } from "react-query";
import QuestionWaitingModal from "./QuestionWaitingModal";
import QuestionCreator from "./QuestionCreator";

const Component = (props) => {
  const { courseId, userId, enrollmentId } = props;

  const {
    data: [question],
  } = useQuery(
    [
      "courses",
      parseInt(courseId, 10),
      "questions",
      "?",
      `enrollment_id=${enrollmentId}`,
      'state=["unresolved", "frozen", "resolving"]',
    ],
    {
      placeholderData: [null],
    }
  );

  const { data: openStatus } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "open_status",
  ]);

  if (question === null || typeof openStatus === "undefined") {
    return (
      <div className="card shadow-sm" style={{ height: "620px" }}>
        <div className="card-body w-100 h-100 w-100 d-flex justify-content-center align-items-center ">
          <div className="spinner-border" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <>
      {question ? (
        <QuestionWaitingModal courseId={courseId} userId={userId} enrollmentId={enrollmentId}  />
      ) : (
        <QuestionCreator courseId={courseId} userId={userId} enrollmentId={enrollmentId} />
      )}
    </>
  );
};

document.addEventListener("turbo:load", (e) => {
  const node = document.querySelectorAll("#student-queue-view");
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
