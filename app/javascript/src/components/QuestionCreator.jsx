import React from "react";
import {useQuery} from "react-query";
import useWrappedMutation from "../hooks/useWrappedMutation";
import Select from "react-select";
import {Controller, useForm} from "react-hook-form";
import DelayedSpinner from "./DelayedSpinner";
import {ErrorMessage, Field, Form, Formik} from 'formik';
import {SelectField} from "./SelectField";

export default (props) => {
    const {userId, courseId, enrollmentId} = props;

    const {data: queues} = useQuery([
        "courses",
        parseInt(courseId, 10),
        "tags",
    ]);


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
                question_tags_attributes: data.tags.map(v => ({
                    tag_id: v
                })),
            }
        }),
        "/api/questions"
    );

    const options = queues
        ?.filter((v) => !v.archived)
        .map((v) => ({
            value: v.id,
            label: v.name,
        }))

    return (
        <div className="card shadow-sm">
            <div className="card-body">
                <Formik
                    initialValues={{
                        description: question?.description,
                        tried: question?.tried,
                        location: question?.location,
                        tags: question?.tags
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
                            const out = await createQuestion(values)
                        } catch (e) {
                        }

                        setTimeout(() => {
                            setSubmitting(false);
                        }, 400);
                    }}
                >
                    {({isSubmitting}) => (
                        <Form>
                            <div className="mb-2">
                                {Object.entries(serverErrors)?.map(([attr, errs]) => (
                                    <div className="invalid-feedback d-block fw-bold">
                                        {errs.map(err => `${attr} ${err}`).join(' and ')}
                                    </div>
                                ))}
                            </div>
                            <ErrorMessage touched name="course" component="div"
                                          className="invalid-feedback d-block fw-bold"/>
                            <div className="mb-1">
                                <label className="form-label fw-bold">
                                    Description
                                </label>
                                <Field type="text" name="description" className="form-control"/>
                                <ErrorMessage name="description" component="div"
                                              className="invalid-feedback d-block fw-bold"/>
                            </div>
                            <div className="mb-1">
                                <label className="form-label fw-bold">
                                    What Have You Tried?
                                </label>
                                <Field type="text" name="tried" className="form-control"/>
                                <ErrorMessage name="tried" component="div"
                                              className="invalid-feedback d-block fw-bold"/>
                            </div>
                            <div className="mb-1">
                                <label className="form-label fw-bold">
                                    Location
                                </label>
                                <Field type="text" name="location" className="form-control"/>
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
                            <button type="submit" disabled={isSubmitting} className="btn btn-primary">
                                Submit
                            </button>
                        </Form>
                    )}
                </Formik>
            </div>
        </div>
    )
};
