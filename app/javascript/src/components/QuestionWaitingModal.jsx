import React, {useEffect, useMemo} from "react";
import {useMutation, useQuery} from "react-query";
import mutationFn from "../utilities/mutationFn";
import useWrappedMutation from "./useWrappedMutation";
import Select from "react-select";
import {Controller, useForm} from "react-hook-form";
import DelayedSpinner from "./DelayedSpinner";

export default function QuestionWaitingModal(props) {
    const {courseId, userId, enrollmentId} = props;


    const {
        data: [question],
        isLoading,
        isFetching,
        refetch,
    } = useQuery(
        [
            "courses",
            parseInt(courseId, 10),
            "questions",
            "?",
            `enrollmentId=${enrollmentId}`,
            'state=["unresolved", "frozen", "resolving"]',
        ],
        {
            placeholderData: [null]
        }
    );


    const {
        register,
        handleSubmit,
        control,
        reset,
        watch,
        setValue,
        formState: {errors: formErrors},
    } = useForm({
        defaultValues: useMemo(() => {
            if (question) {
                console.log('here', question)
                return {
                    queues:
                        question.tags
                            .filter((v) => !v.archived)
                            .map((v) => ({
                                value: v.id,
                                label: v.name,
                            })),

                    description:
                    question.description,
                    location:
                    question.location
                    ,
                    tried:
                    question.tried
                }
            }

        }, [question])
    });

    useEffect(() => {
        if(question) {
            return reset({
                queues:
                    question.tags
                        .filter((v) => !v.archived)
                        .map((v) => ({
                            value: v.id,
                            label: v.name,
                        })),

                description:
                question.description,
                location:
                question.location
                ,
                tried:
                question.tried
            })
        }
    }, [question])


    const {data: queues} = useQuery(
        ["courses", parseInt(courseId, 10), "tags"],
    );
    const {mutateAsync: updateQuestion, isLoading: updatedLoading} =
        useWrappedMutation(
            () => ({
                question: {
                    description: formFields.description,
                    tried: formFields.tried,
                    location: formFields.location,
                    tags: formFields.queues.map((v) => v.value),
                },
            }),
            `/questions/${question?.id}`,
            {
                method: "PATCH",
            }
        );

    const {mutateAsync: unfreeze} = useWrappedMutation(
        () => ({
            question_state: {
                state: "unresolved",
                user_id: userId,
                question_id: question.id,
            },
        }),
        "/question_states"
    );


    const {mutateAsync: deleteQuestion, isLoading: deleteLoading} = useMutation(
        () =>
            mutationFn(`/questions/${question?.id}`, {
                method: "DELETE",
            })
    );

    let title = "";
    let border = "";
    if (question?.question_state?.state === "frozen") {
        title = "Frozen";
        border = "4px solid #2185D0";
    } else if (question?.question_state?.state === "unresolved") {
        title = "Waiting";
    } else if (question?.question_state?.state === "resolving") {
        title = "Resolving";
        border = "4px solid #21BA45";
    } else if (question?.question_state?.state === "kicked") {
        title = "Kicked";
    }
    const formFields = watch();

    console.log(formFields)

    return (
        <div style={{border, height: "700px"}} className="card shadow-sm">
            <div className="card-body h-100">
                <h1>{title}</h1>
                <form>
                    <div className="mb-2">
                        <label className="form-label"> Queue </label>
                        <Controller
                            name="queues"
                            control={control}
                            render={({field}) => {
                                return (
                                    <Select
                                        className={formErrors?.queues ? "err" : ""}
                                        {...field}
                                        value={formFields.queues}
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
                                    checkLength: (v) => typeof v !== "undefined" && v.length > 0,
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
                        <label className="form-label"> Description </label>
                        <textarea
                            rows={3}
                            className={`form-control ${
                                formErrors.description ? "is-invalid" : ""
                            }`}
                            {...register("description", {
                                value: question?.description,
                                required: {
                                    value: true,
                                    message: "Description is required.",
                                },
                            })}
                        />
                        {formErrors.description && (
                            <span className="invalid-feedback d-block">
                {formErrors?.description?.message}
              </span>
                        )}
                    </div>
                    <div className="mb-2">
                        <label className="form-label"> Tried </label>
                        <textarea
                            className={`form-control ${formErrors.tried ? "is-invalid" : ""}`}
                            {...register("tried", {
                                value: question?.tried,
                                required: {
                                    value: true,
                                    message: "What you tried is required.",
                                },
                            })}
                        />
                        {formErrors.description && (
                            <span className="invalid-feedback d-block">
                {formErrors?.tried?.message}
              </span>
                        )}
                    </div>
                    <div>
                        <label className="form-label"> Location </label>
                        <textarea
                            rows={3}
                            className={`form-control ${
                                formErrors.location ? "is-invalid" : ""
                            }`}
                            {...register("location", {
                                value: question?.location,
                                required: {
                                    value: true,
                                    message: "Location is required.",
                                },
                            })}
                        />
                        {formErrors.description && (
                            <span className="invalid-feedback d-block">
                {formErrors?.location?.message}
              </span>
                        )}
                    </div>
                </form>
            </div>
            <div
                className="card-footer"
                style={{
                    display: "grid",
                    gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))",
                    columnGap: "10px",
                }}
            >
                <button
                    className="btn btn-success"
                    disabled={
                        formFields.tried === question?.tried &&
                        formFields.description === question?.description &&
                        formFields.location === question?.location &&
                        formFields.queues &&
                        formFields?.queues?.length === question?.tags.length &&
                        question?.tags
                            ?.map((v) => v.id)
                            .every((v, i) => v === formFields?.queues[i].value) &&
                        formFields?.queues?.every(
                            (v, i) => v.value === question?.tags?.map((v) => v.id)[i]
                        )
                    }
                    onClick={handleSubmit(async (e) => {
                        await updateQuestion();
                    })}
                >
                    <DelayedSpinner loading={updatedLoading}>Change</DelayedSpinner>
                </button>
                {question?.question_state.state === "frozen" ? (
                    <button
                        className="btn btn-primary"
                        onClick={(e) => {
                            try {
                                unfreeze();
                            } catch (e) {
                            }
                        }}
                    >
                        Unfreeze
                    </button>
                ) : null}
                <button
                    className="btn btn-danger"
                    onClick={async (e) => {
                        await deleteQuestion();
                    }}
                    load
                >
                    <DelayedSpinner loading={deleteLoading}>Delete</DelayedSpinner>
                </button>
            </div>
        </div>
    );
}
