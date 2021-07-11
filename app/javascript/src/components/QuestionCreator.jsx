import React, {useRef} from "react";
import {useMutation, useQuery} from "react-query";
import useWrappedMutation from "../hooks/useWrappedMutation";
import {useForm} from "react-hook-form";
import {ErrorMessage, Field, Form, Formik} from 'formik';
import {SelectField} from "./SelectField";
import mutationFn from "../utilities/mutationFn";
import DelayedSpinner from "./DelayedSpinner";
import ServerError from "./ServerError";

export default (props) => {
    const {userId, courseId, enrollmentId} = props;

    const {data: queues} = useQuery([
        "courses",
        parseInt(courseId, 10),
        "tags",
    ]);

    const formRef = useRef()


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

    const {data: openStatus} = useQuery([
        "courses",
        parseInt(courseId, 10),
        "open_status",
    ]);

    const {
        register,
        handleSubmit,
        control,
        formState: {errors: formErrors},
    } = useForm();

    const {
        mutateAsync: createQuestion,
        isLoading,
        errors: serverErrors,
    } = useWrappedMutation(
        (data) => ({
            question: {
                description: data.description,
                tried: data.tried,
                location: data.location,
                enrollment_id: enrollmentId,
                course_id: courseId,
            },
            tags: data.tags
        }),
        "/api/questions"
    );

    const {mutateAsync: updateQuestion, isLoading: updatedLoading} =
        useWrappedMutation(
            (data) => ({
                question: {
                    description: data.description,
                    tried: data.tried,
                    location: data.location,
                },
                tags: data.tags,
            }),
            `/api/questions/${question?.id}`,
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
        "/api/question_states"
    );


    const {mutateAsync: deleteQuestion, isLoading: deleteLoading} = useMutation(
        () =>
            mutationFn(`/questions/${question?.id}`, {
                method: "DELETE",
            })
    );


    const options = queues
        ?.filter((v) => !v.archived)
        .map((v) => ({
            value: v.id,
            label: v.name,
        }))

    console.log(question)

    return (
        <div className="card shadow-sm">
            <div className="card-body">
                <Formik
                    innerRef={formRef}
                    initialValues={{
                        description: question?.description,
                        tried: question?.tried,
                        location: question?.location,
                        tags: question?.tags.map(v => v.id)
                    }}
                    validate={values => {
                        const {description, tried, location, tags} = values;
                        const errors = {};
                        if (!description) {
                            errors.description = 'Required';
                        } else if (!tried) {
                            errors.tried = 'Required';
                        } else if (!location) {
                            errors.location = 'Required';
                        } else if (!tags || tags?.length < 1) {
                            errors.tags = 'Select at least 1 tag.';
                        }

                        return errors;
                    }}
                    onSubmit={async (values, {setSubmitting, setErrors}) => {
                        try {
                            if (question) {
                                const out = await updateQuestion(values)
                            } else {
                                const out = await createQuestion(values)
                            }
                        } catch (e) {
                        }

                        setTimeout(() => {
                            setSubmitting(false);
                        }, 400);
                    }}
                >
                    {({isSubmitting}) => (
                        <Form>
                            <ServerError error={serverErrors}/>
                            <ErrorMessage touched name="course" component="div"
                                          className="invalid-feedback d-block fw-bold"/>
                            <div className="mb-1">
                                <label className="form-label fw-bold">
                                    Description
                                </label>
                                <Field as="textarea" name="description" className="form-control"/>
                                <ErrorMessage name="description" component="div"
                                              className="invalid-feedback d-block fw-bold"/>
                            </div>
                            <div className="mb-1">
                                <label className="form-label fw-bold">
                                    What Have You Tried?
                                </label>
                                <Field as="textarea" name="tried" className="form-control"/>
                                <ErrorMessage name="tried" component="div"
                                              className="invalid-feedback d-block fw-bold"/>
                            </div>
                            <div className="mb-1">
                                <label className="form-label fw-bold">
                                    Location
                                </label>
                                <Field as="textarea" name="location" className="form-control"/>
                                <ErrorMessage name="location" component="div"
                                              className="invalid-feedback d-block fw-bold"/>
                            </div>

                            <div className="mb-3">
                                <label className="form-label fw-bold">
                                    Tags
                                </label>
                                <Field name='tags' component={SelectField} options={options} isMulti/>
                                <ErrorMessage name="tags" component="div" className="invalid-feedback d-block fw-bold"/>
                            </div>
                            {
                                question ? (
                                    <div>
                                        <button type="submit"
                                                disabled={(
                                                    formRef.current?.values?.tried === question?.tried &&
                                                    formRef.current?.values?.description === question?.description &&
                                                    formRef.current?.values?.location === question?.location &&
                                                    formRef.current?.values?.tags &&
                                                    formRef.current?.values?.tags?.length === question?.tags.length &&
                                                    question?.tags
                                                        ?.map((v) => v.id)
                                                        .every((v, i) => v === formRef.current?.values?.tags[i]) &&
                                                    formRef.current?.values?.tags?.every(
                                                        (v, i) => v === question?.tags?.map((v) => v.id)[i]
                                                    )
                                                )}
                                                className="btn btn-primary me-2">
                                            Update
                                        </button>
                                        <button
                                            className="btn btn-danger"
                                            onClick={async (e) => {
                                                e.preventDefault()
                                                await deleteQuestion();
                                            }}
                                        >
                                            <DelayedSpinner loading={deleteLoading}>Delete</DelayedSpinner>
                                        </button>
                                    </div>
                                ) : (
                                    <button type="submit" disabled={isSubmitting} className="btn btn-primary">
                                        Ask Question
                                    </button>
                                )
                            }
                        </Form>
                    )}
                </Formik>
            </div>
        </div>
    )
};
