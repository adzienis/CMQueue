import React from 'react'
import {useMutation, useQuery} from "react-query";
import mutationFn from "./mutationFn";
import useWrappedMutation from "./useWrappedMutation";
import Select from "react-select";
import {Controller, useForm} from "react-hook-form";
import DelayedSpinner from "./DelayedSpinner";


export default function QuestionWaitingModal(props) {

    const {courseId, userId} = props;


    const {register, handleSubmit, control, watch, setValue, formState: {errors: formErrors}} = useForm();

    const {data: [question], isLoading, isFetching, refetch} = useQuery(['courses',
        parseInt(courseId, 10),
        'questions', '?', `user_id=${userId}`, 'state=["unresolved", "frozen", "resolving"]'], {
        placeholderData: [null], onSuccess: d => {
            if (d.length > 0) {
                setValue(
                    "queues", d[0].tags.filter(v => !v.archived).map(v => ({
                        value: v.id, label: v.name
                    }))
                )
            }
        }
    })

    const {data: messages} = useQuery(['questions', question?.id, 'messages'], {
        enabled: !!question
    })

    const {data: queues} = useQuery(['courses', parseInt(courseId, 10), 'tags'], {
        placeholderData: []
    })
    const {mutateAsync: updateQuestion, isLoading: updatedLoading} = useWrappedMutation(() => ({
        question: {
            description: formFields.description,
            tried: formFields.tried,
            location: formFields.location,
            tags: formFields.queues.map(v => v.value)
        }
    }), `/questions/${question?.id}`, {
        method: 'PATCH'
    })

    const {mutateAsync: unfreeze} = useWrappedMutation(() => ({
        question_state: {
            state: 'unresolved',
            user_id: userId,
            question_id: question.id
        }
    }), '/question_states')

    const {mutateAsync: clearMessage} = useWrappedMutation(({id}) => ({
        message: {
            id,
            seen: true
        }, url: `/messages/${id}`
    }), '/messages', {
        method: 'PATCH'
    })

    const {
        mutateAsync: deleteQuestion,
        isLoading: deleteLoading
    } = useMutation(() => mutationFn(`/questions/${question?.id}`, {
        method: 'DELETE'
    }), {
        onSuccess: d => {
            Turbo.visit(window.location.toString(), {action: 'replace'})
        }
    })

    let title = '';
    let border = '';
    if (question?.question_state?.state === "frozen") {
        title = "Frozen";
        border = '4px solid #2185D0';
    } else if (question?.question_state?.state === "unresolved") {
        title = "Waiting"
    } else if (question?.question_state?.state === "resolving") {
        title = "Resolving"
        border = '4px solid #21BA45';
    } else if (question?.question_state?.state === "kicked") {
        title = "Kicked"
    }
    const formFields = watch();


    return (
        <div  style={{border, height: '700px'}} className="card shadow-sm">
            <div className="card-body h-100">
                <h1>
                    {title}
                </h1>
                {messages?.filter(v => !v.seen).map(v => <div>
                    <div className='alert alert-primary'>
                        <h5 className='alert-heading' style={{display: 'flex'}}>
                            <div style={{flex: 1}}>
                                <p className='mb-1'>
                                    {v.question_state.state}
                                </p>
                                <p>
                                    {v.created_at}
                                </p>
                            </div>
                            <a href='' onClick={e => {
                                e.preventDefault()
                                try {
                                    clearMessage({
                                        id: v.id
                                    })
                                } catch (e) {

                                }
                            }}>
                                <i className="fas fa-times fa-lg"/>
                            </a>
                        </h5>

                        <div>
                            {v.description}
                        </div>
                    </div>
                </div>)}
                <form>
                    <div className="mb-2">
                        <label className="form-label"> Queue </label>
                        <Controller
                            name="queues"
                            control={control}
                            defaultValue={question?.tags?.map(v => ({
                                value: v.id,
                                label: v.name
                            }))}
                            render={({field}) => {
                                return <Select
                                    className={formErrors?.queues ? "err" : ""}
                                    {...field}
                                    value={formFields.queues}
                                    isMulti
                                    options={queues.filter(v => !v.archived).map(v => ({
                                        value: v.id, label: v.name
                                    }))}
                                />
                            }
                            }
                            rules={{
                                minLength: 3,
                                validate: {
                                    checkLength: v => (typeof v !== "undefined" && (v.length > 0))
                                }
                            }}
                        />
                        {formErrors?.queues?.type === "checkLength" && <span className="invalid-feedback d-block">
                                    "Select at least one queue"
                                </span>}
                    </div>
                    <div className="mb-2">
                        <label className="form-label"> Description </label>
                        <textarea
                            rows={3}
                            className={`form-control ${formErrors.description ? "is-invalid" : ""}`}
                            {...register("description", {
                                value: question?.description,
                                required: {
                                    value: true,
                                    message: "Description is required."
                                }
                            })}
                        />
                        {formErrors.description && <span className="invalid-feedback d-block">
                                    {formErrors?.description?.message}
                                </span>}
                    </div>
                    <div className="mb-2">
                        <label className="form-label"> Tried </label>
                        <textarea
                            className={`form-control ${formErrors.tried ? "is-invalid" : ""}`}
                            {...register("tried", {
                                value: question?.tried,
                                required: {
                                    value: true,
                                    message: "What you tried is required."
                                }
                            })}
                        />
                        {formErrors.description && <span className="invalid-feedback d-block">
                                    {formErrors?.tried?.message}
                                </span>}
                    </div>
                    <div>
                        <label className="form-label"> Location </label>
                        <textarea
                            rows={3}
                            className={`form-control ${formErrors.location ? "is-invalid" : ""}`}
                            {...register("location", {
                                value: question?.location,
                                required: {
                                    value: true,
                                    message: "Location is required."
                                }
                            })}
                        />
                        {formErrors.description && <span className="invalid-feedback d-block">
                                    {formErrors?.location?.message}
                                </span>}
                    </div>
                </form>
            </div>
            <div
                className="card-footer"
                style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
                    columnGap: '10px'
                }}>
                <button className="btn btn-success"
                        disabled={(formFields.tried === question?.tried &&
                            formFields.description === question?.description &&
                            formFields.location === question?.location &&
                            formFields.queues &&
                            formFields?.queues?.length === question?.tags.length &&
                            question?.tags?.map(v => v.id).every((v, i) => v === formFields?.queues[i].value) &&
                            formFields?.queues?.every((v, i) => v.value === question?.tags?.map(v => v.id)[i]))}
                        onClick={handleSubmit(async e => {
                            await updateQuestion()
                        })}

                >
                    <DelayedSpinner loading={updatedLoading}>
                        Change
                    </DelayedSpinner>
                </button>
                {question?.question_state.state === "frozen" ? <button className="btn btn-primary"
                    onClick={e => {
                        try {
                            unfreeze()
                        } catch (e) {

                        }
                    }}>
                    Unfreeze
                </button> : null}
                <button className="btn btn-danger"
                    onClick={async e => {
                        await deleteQuestion()
                    }}
                    load
                >
                    <DelayedSpinner loading={deleteLoading}>
                        Delete
                    </DelayedSpinner>
                </button>
            </div>
        </div>
    )
}