import React, { useEffect, useRef, useState } from "react";
import { useQuery } from "react-query";
import useWrappedMutation from "../hooks/useWrappedMutation";
import CourseCard from "./CourseCard";
import AsyncSelect from "react-select/async";
import Select from "react-select";

export default (props) => {
  const { userId } = props;
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState([]);
  const { data } = useQuery(["courses", "search", "?", `name=${search}`], {
    select: (data) => {
      return data.map((v) => ({ label: v.name, value: v.id }));
    },
  });

  const { data: allCourses } = useQuery(["courses", "search"]);

  const { data: enrollments } = useQuery([
    "users",
    parseInt(userId, 10),
    "enrollments",
    "?",
    "role=student",
  ]);

  const {
    mutate: addCourse,
    errors,
    setErrors,
  } = useWrappedMutation(
    (course_id) => ({
      course_id,
      user_id: userId,
    }),
    "/api/enrollments",
    {}
  );

  useEffect(() => {
    if (!open) setErrors({});
  }, [open]);

  return (
    <>
      <div className="modal fade" id="search-modal">
        <div className="modal-dialog modal-dialog-centered modal-lg">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title">Course Search</h5>
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              />
            </div>
            <div className="modal-body">
              <div className="mb-3">
                <label className="form-label fw-bold mb-0">Search</label>
                <div className="text-muted">
                  Search for a course by its name, if it is open for enrollment.
                </div>
                <Select
                  isMulti
                  options={data}
                  onInputChange={(newValue) => {
                    setSearch(newValue);
                  }}
                  onChange={(options) => setSelected(options)}
                />
              </div>
              <button
                className="btn btn-primary"
                onClick={(e) => {
                  selected.map((v) => {
                    try {
                      addCourse(v.value);
                    } catch (e) {}
                  });
                }}
              >
                Add Course
              </button>
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
          data-bs-target="#search-modal"
        >
          <div
            className="card-body"
            style={{ display: "flex", justifyContent: "center" }}
          >
            <div className="d-flex flex-column justify-content-center align-items-center">
              <i className="fas fa-plus fa-2x text-primary" />
              <div> Add a Course </div>
            </div>
          </div>
        </a>
        {enrollments?.map((v) => (
          <CourseCard enrollment={v} />
        ))}
      </div>
    </>
  );
};
