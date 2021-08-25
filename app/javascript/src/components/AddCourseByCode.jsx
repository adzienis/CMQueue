import React, { useState } from "react";
import { useQuery } from "react-query";

import useWrappedMutation from "../hooks/useWrappedMutation";
import CourseCard from "./CourseCard";

/**
 * Add a course by role code.
 *
 * Requires a valid TA or instructor code.
 * @param props
 * @returns {JSX.Element}
 */
export default (props) => {
  const { userId } = props;

  const { data: enrollments } = useQuery([
    "users",
    parseInt(userId, 10),
    "enrollments",
    "?",
    "role=ta",
  ]);

  const { data: instructor_enrollments } = useQuery([
    "users",
    parseInt(userId, 10),
    "enrollments",
    "?",
    "role=instructor",
  ]);

  const { mutateAsync: createEnrollment, errors } = useWrappedMutation(
    () => ({
      enrollment: {
        code,
      },
    }),
    `/user/enrollments`,
    {
      method: "POST",
    }
  );
  const [code, setCode] = useState("");
  return (
    <>
      <div className="modal fade" id="course-code-modal">
        <div className="modal-dialog modal-dialog-centered modal-lg">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title">Add Course By Role Code</h5>
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              />
            </div>
            <div className="modal-body">
              <form>
                <div className="mb-3">
                  <div className="mb-2">
                    <label className="form-label fw-bold mb-0">
                      {" "}
                      Role Code{" "}
                    </label>
                    <div className="text-muted">
                      Enter the specific course role code given to you by an
                      instructor.
                    </div>
                  </div>
                  <input
                    className="form-control"
                    value={code}
                    onChange={(e) => setCode(e.target.value)}
                  />
                  <b>
                    <div className="invalid-feedback d-block">
                      {Object.values(errors).flat().join(", and ")}
                    </div>
                  </b>
                </div>
                <button
                  className="btn btn-primary"
                  onClick={(e) => {
                    e.preventDefault();

                    try {
                      createEnrollment();
                    } catch (e) {}
                  }}
                >
                  Submit
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
      <div
        style={{ display: "grid", gridTemplateColumns: "1fr", rowGap: "1rem" }}
      >
        <a
          href=""
          className="card shadow-sm hover-container"
          data-bs-toggle="modal"
          data-bs-target="#course-code-modal"
        >
          <div
            className="card-body"
            style={{ display: "flex", justifyContent: "center" }}
          >
            <div className="d-flex flex-column justify-content-center align-items-center">
              <i className="fas fa-plus fa-2x" />
              <div> Add a Course </div>
            </div>
          </div>
        </a>
        {enrollments && instructor_enrollments
          ? enrollments
              .concat(instructor_enrollments)
              .map((v) => <CourseCard enrollment={v} />)
          : null}
      </div>
    </>
  );
};
