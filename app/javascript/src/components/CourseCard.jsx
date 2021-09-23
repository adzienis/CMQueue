import useWrappedMutation from "../hooks/useWrappedMutation";
import React, { useMemo } from "react";
import { useQuery } from "react-query";

export default (props) => {
  const { enrollment } = props;

  const { mutateAsync: deleteEnrollment } = useWrappedMutation(
    () => ({}),
    `/enrollments/${enrollment.id}`,
    {
      method: "DELETE",
    }
  );

  let footerClass = "";
  let href = "";

  if (enrollment.role.name === "instructor") {
    footerClass = "bg-success";
    href = `/courses/${enrollment.course.id}/queue`;
  } else if (enrollment.role.name === "ta") {
    footerClass = "bg-info";
    href = `/courses/${enrollment.course.id}/queue`;
  } else if (enrollment.role.name === "student") {
    footerClass = "bg-warning";
    href = `/courses/${enrollment.course.id}/forms/question/new`;
  }

  return (
    <a
      href={href}
      className="card shadow-sm text-decoration-none hover-container"
      style={{ color: "inherit" }}
    >
      <div className="card-body">
        <div className="card-title">
          <div style={{ display: "flex" }}>
            <h5 style={{ flex: 1 }}>
              Go to <b>{enrollment.course.name}</b>
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
      <div
        className={`card-footer text-white  ${footerClass}`}
        style={{ textTransform: "capitalize" }}
      >
        {enrollment?.role.name}
      </div>
    </a>
  );
};
