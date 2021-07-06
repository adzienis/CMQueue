import useWrappedMutation from "../hooks/useWrappedMutation";
import React from "react";
import { useQuery } from "react-query";

export default (props) => {
  const { course } = props;

  // should just reference course above to enrollment so no n+1
  const {
    data: [enrollment_data],
  } = useQuery(["enrollments", "?", `course_id=${course?.id}`], {
    placeholderData: [undefined],
  });
  const { mutateAsync: deleteEnrollment } = useWrappedMutation(
    () => ({}),
    `/api/enrollments/${enrollment_data?.id}`,
    {
      method: "DELETE",
    }
  );

  return (
    <a
      href={`/courses/${course?.id}/queue`}
      className="card shadow-sm text-decoration-none hover-container"
      style={{ color: "inherit" }}
    >
      <div className="card-body">
        <div className="card-title">
          <div style={{ display: "flex" }}>
            <h5 style={{ flex: 1 }}>
              Go to <b>{course?.name}</b>
            </h5>
            <i
              className="fas fa-times fa-lg"
              onClick={(e) => {
                e.preventDefault();
                try {
                  deleteEnrollment();
                } catch (e) {}
              }}
            />
          </div>
        </div>
      </div>
    </a>
  );
};
