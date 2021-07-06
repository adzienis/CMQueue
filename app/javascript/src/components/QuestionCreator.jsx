import React from "react";
import { useQuery } from "react-query";
import useWrappedMutation from "../hooks/useWrappedMutation";
import Select from "react-select";
import { Controller, useForm } from "react-hook-form";
import DelayedSpinner from "./DelayedSpinner";

export default (props) => {
  const { userId, courseId, enrollmentId } = props;

  const { data: queues } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "tags",
  ]);

  const { data: openStatus } = useQuery([
    "courses",
    parseInt(courseId, 10),
    "open_status",
  ]);

  const {
    register,
    handleSubmit,
    control,
    formState: { errors: formErrors },
  } = useForm();

  const {
    mutateAsync: createQuestion,
    isLoading,
    errors,
  } = useWrappedMutation(
    (data) => ({
      question: {
        description: data.description,
        tried: data.tried,
        location: data.location,
        enrollment_id: enrollmentId,
        course_id: courseId,
        tags: data.queues.map((v) => v.value),
      },
      tags: data.queues.map((v) => v.value),
    }),
    "/api/questions"
  );

  return (
    <div>
      <div>
        {(() => {
          if (errors?.error) {
            try {
              const json = JSON.parse(errors.error);

              return Object.entries(json).map((v) => (
                <div className="alert alert-danger">{`${v[0]} ${v[1]}`}</div>
              ));
            } catch (e) {
              console.log(errors?.error);
            }
          }
        })()}
      </div>
      {!openStatus ? (
        <>
          <div className="position-relative">
            <div className="position-absolute w-100 h-100 d-flex justify-content-center align-items-center">
              <h1 className="text-danger"></h1>
            </div>

            <div className="card shadow-sm" style={{ height: "620px" }}>
              <div
                className="card-body"
                style={{ opacity: 0.3, pointerEvents: "none" }}
              >
                <h1>Ask a Question</h1>
                <form>
                  <div className="mb-2">
                    <label className="form-label fw-bold"> Queue </label>
                    <Controller
                      name="queues"
                      control={control}
                      render={({ field }) => {
                        return (
                          <Select
                            className={formErrors?.queues ? "err" : ""}
                            {...field}
                            isMulti
                            options={queues
                              ?.filter((v) => !v.archived)
                              .map((v) => ({
                                value: v.id,
                                label: v.name,
                              }))}
                          />
                        );
                      }}
                      rules={{
                        minLength: 3,
                        validate: {
                          checkLength: (v) =>
                            typeof v !== "undefined" && v.length > 0,
                        },
                      }}
                    />
                    {formErrors?.queues?.type === "checkLength" && (
                      <span className="invalid-feedback d-block">
                        "Select at least one queue"
                      </span>
                    )}
                  </div>
                  <div className="mb-2">
                    <label className="form-label fw-bold"> Description </label>
                    <textarea
                      rows={3}
                      className={`form-control ${
                        formErrors.description ? "is-invalid" : ""
                      }`}
                      {...register("description", {
                        required: {
                          value: true,
                          message: "Description is required.",
                        },
                      })}
                    />
                    {
                      <span className="invalid-feedback d-block">
                        {formErrors?.description?.message}
                      </span>
                    }
                  </div>
                  <div className="mb-2">
                    <label className="form-label fw-bold"> Tried </label>
                    <textarea
                      className={`form-control ${
                        formErrors.tried ? "is-invalid" : ""
                      }`}
                      {...register("tried", {
                        required: {
                          value: true,
                          message: "What you tried is required.",
                        },
                      })}
                      rows={3}
                    />
                    {formErrors.tried && (
                      <span className="invalid-feedback d-block">
                        {formErrors?.tried?.message}
                      </span>
                    )}
                  </div>
                  <div className="mb-3">
                    <label className="form-label fw-bold"> Location </label>
                    <textarea
                      rows={3}
                      className={`form-control ${
                        formErrors.location ? "is-invalid" : ""
                      }`}
                      {...register("location", {
                        required: {
                          value: true,
                          message: "Location is required.",
                        },
                      })}
                    />
                    {formErrors.location && (
                      <span className="invalid-feedback d-block">
                        {formErrors?.location?.message}
                      </span>
                    )}
                  </div>
                  <button
                    className="btn btn-primary"
                    onClick={handleSubmit((data) => {
                      try {
                        createQuestion(data);
                      } catch (e) {}
                    })}
                  >
                    <DelayedSpinner loading={isLoading}>Submit</DelayedSpinner>
                  </button>
                </form>
              </div>
            </div>
          </div>
        </>
      ) : (
        <div className="card shadow-sm" style={{ height: "620px" }}>
          <div className="card-body">
            <h1>Ask a Question</h1>
            <form>
              <div className="mb-2">
                <label className="form-label fw-bold"> Queue </label>
                <Controller
                  name="queues"
                  control={control}
                  render={({ field }) => {
                    return (
                      <Select
                        className={formErrors?.queues ? "err" : ""}
                        {...field}
                        isMulti
                        options={queues
                          ?.filter((v) => !v.archived)
                          .map((v) => ({
                            value: v.id,
                            label: v.name,
                          }))}
                      />
                    );
                  }}
                  rules={{
                    minLength: 3,
                    validate: {
                      checkLength: (v) =>
                        typeof v !== "undefined" && v.length > 0,
                    },
                  }}
                />
                {formErrors?.queues?.type === "checkLength" && (
                  <span className="invalid-feedback d-block">
                    "Select at least one queue"
                  </span>
                )}
              </div>
              <div className="mb-2">
                <label className="form-label fw-bold"> Description </label>
                <textarea
                  rows={3}
                  className={`form-control ${
                    formErrors.description ? "is-invalid" : ""
                  }`}
                  {...register("description", {
                    required: {
                      value: true,
                      message: "Description is required.",
                    },
                  })}
                />
                {
                  <span className="invalid-feedback d-block">
                    {formErrors?.description?.message}
                  </span>
                }
              </div>
              <div className="mb-2">
                <label className="form-label fw-bold"> Tried </label>
                <textarea
                  rows={3}
                  className={`form-control ${
                    formErrors.tried ? "is-invalid" : ""
                  }`}
                  {...register("tried", {
                    required: {
                      value: true,
                      message: "What you tried is required.",
                    },
                  })}
                />
                {formErrors.tried && (
                  <span className="invalid-feedback d-block">
                    {formErrors?.tried?.message}
                  </span>
                )}
              </div>
              <div className="mb-3">
                <label className="form-label fw-bold"> Location </label>
                <textarea
                  rows={3}
                  className={`form-control ${
                    formErrors.location ? "is-invalid" : ""
                  }`}
                  {...register("location", {
                    required: {
                      value: true,
                      message: "Location is required.",
                    },
                  })}
                />
                {formErrors.location && (
                  <span className="invalid-feedback d-block">
                    {formErrors?.location?.message}
                  </span>
                )}
              </div>
              <button
                className="btn btn-primary"
                onClick={handleSubmit((data) => {
                  try {
                    createQuestion(data);
                  } catch (e) {}
                })}
              >
                <DelayedSpinner loading={isLoading}>Submit</DelayedSpinner>
              </button>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
