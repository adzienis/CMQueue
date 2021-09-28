import React, { useEffect, useState } from "react";
import { useQuery } from "react-query";
import useWrappedMutation from "../hooks/useWrappedMutation";
import CourseCard from "./CourseCard";
import Select from "react-select";
import { Controller, useForm } from "react-hook-form";
import defaultMutationFn from "../utilities/defaultMutationFn";
import ErrorSummary from "./forms/ErrorSummary";

export default (props) => {
  const { userId } = props;

  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const { data } = useQuery(["courses", "?", `name=${search}`], {
    select: (data) => {
      return data.map((v) => ({ label: v.name, value: v.id }));
    },
  });

  const { data: enrollments } = useQuery([
    "users",
    parseInt(userId, 10),
    "enrollments",
    "?",
    `role=${JSON.stringify(["student"])}`,
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
    `/enroll`
  );

  useEffect(() => {
    if (!open) setErrors({});
  }, [open]);

  const {
    register,
    handleSubmit,
    watch,
    control,
    setError,
    reset,
    clearErrors,
    formState: { errors: formErrors },
  } = useForm();

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
              <ErrorSummary errors={formErrors} />
              <form onChange={(e) => clearErrors(["course", "enrollment"])}>
                <div className="mb-2">
                  <label className="form-label fw-bold mb-0">Search</label>
                  <div className="text-muted">
                    Search for a course by its name, if it is open for
                    enrollment.
                  </div>
                  <Controller
                    name="course_name"
                    control={control}
                    render={({ field }) => (
                      <Select {...field} isMulti options={data} />
                    )}
                  />
                </div>

                <button
                  className="btn btn-primary"
                  onClick={handleSubmit(async (data) => {
                    const resp = await defaultMutationFn("/enroll", {
                      body: {
                        course_id: data["course_name"][0].value,
                      },
                    });

                    if (resp.errors) {
                      Object.keys(resp.errors).forEach((key) => {
                        setError(key, {
                          type: "server",
                          message: key + " " + resp.errors[key].join(", "),
                        });
                      });
                    }
                  })}
                >
                  Add Course
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
          data-bs-target="#search-modal"
        >
          <div
            className="card-body"
            style={{ display: "flex", justifyContent: "center" }}
          >
            <div className="d-flex flex-column justify-content-center align-items-center">
              <i className="fas fa-plus fa-2x text-primary" />
              <div> Add a Course</div>
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
