// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, { useEffect, useState } from "react";
import ReactDOM from "react-dom";
import { QueryClientProvider, useQuery } from "react-query";
import useWrappedMutation from "./useWrappedMutation";
import CourseCard from "./CourseCard";

export default (props) => {
  const { userId } = props;
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const { data } = useQuery(["courses", "search", "?", `name=${search}`], {
    select: (data) => {
      if (search === "") return [];

      return data.map((v) => ({ title: v.name, id: v.id }));
    },
  });

  const { data: allCourses } = useQuery(["courses", "search"]);

  const { data: courses } = useQuery([
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
    }),
    "/api/enrollments",
    {}
  );

  useEffect(() => {
    if (!open) setErrors({});
  }, [open]);

  let searchResults = null;

  if (data?.length === 0 && search === "") {
    searchResults = null;
  } else if (data?.length === 0 && search !== null && search !== "") {
    searchResults = (
      <ul className="list-group position-relative">
        <li className="list-group-item position-absolute w-100">
          No courses found by this name
        </li>
      </ul>
    );
  } else if (data?.length > 0) {
    searchResults = data?.map((v) => (
      <li
        className="list-group-item w-100"
        style={{ cursor: "pointer" }}
        value={v.id}
        onClick={(e) => {
          addCourse(e.target.value);
        }}
      >
        {v.title}
      </li>
    ));
  }

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
              ></button>
            </div>
            <div className="modal-body">
              <div>
                <div className="w-100 mb-3">
                  <label className="form-label">
                    <b>Courses</b>
                  </label>
                  <input
                    className="form-control"
                    type="text"
                    onChange={(e) => {
                      setSearch(e.target.value);
                    }}
                  />
                  {
                    <ul className="list-group position-relative">
                      <div
                        className="position-absolute w-100"
                        style={{ zIndex: "10" }}
                      >
                        {searchResults}
                      </div>
                    </ul>
                  }
                </div>

                <div
                  className="accordion position-relative w-100"
                  id="accordionExample"
                >
                  <div className="accordion-item">
                    <h2 className="accordion-header" id="headingOne">
                      <button
                        className="accordion-button"
                        type="button"
                        data-bs-toggle="collapse"
                        data-bs-target="#collapseOne"
                        aria-expanded="true"
                        aria-controls="collapseOne"
                      >
                        <b>All Courses</b>
                      </button>
                    </h2>
                    <div
                      id="collapseOne"
                      className="accordion-collapse position-absolute w-100 collapse"
                      aria-labelledby="headingOne"
                      data-bs-parent="#accordionExample"
                    >
                      <div className="accordion-body p-0">
                        <ul
                          className="list-group border"
                          style={{ maxHeight: "300px", overflowY: "scroll" }}
                        >
                          {typeof allCourses === "undefined" || allCourses.length === 0 ? (
                              <div className="alert alert-warning h-100 mb-0">
                                No courses
                              </div>
                          ) : (
                              allCourses?.map((v) => (
                                  <a
                                      href=""
                                      className="list-group-item"
                                      onClick={(e) => {
                                        e.preventDefault();
                                        try {
                                          addCourse(v.id);
                                        } catch (e) {}
                                      }}
                                  >
                                    Enroll in <b>{v.name}</b>
                                  </a>
                              ))
                          )}
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
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
            <i className="fas fa-plus fa-2x" />
          </div>
        </a>
        {courses?.map((v) => (
          <CourseCard course={v} />
        ))}
      </div>
    </>
  );
};
