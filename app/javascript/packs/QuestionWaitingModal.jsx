import React, {useEffect, useState} from 'react'
import {useMutation, useQuery} from "react-query";
import mutationFn from "./mutationFn";
import useWrappedMutation from "./useWrappedMutation";
import {Button, Card, Form, Spinner} from "react-bootstrap";
import Select from "react-select";
import {Controller, useForm} from "react-hook-form";


export default function QuestionWaitingModal(props) {

    const {courseId, userId} = props;

    const {data: [question], isLoading, isFetching, refetch} = useQuery(['courses',
        parseInt(courseId, 10),
        'questions', '?', `user_id=${userId}`, 'state=["unresolved", "frozen", "resolving"]'], {
        placeholderData: []
    })

    useEffect(() => {
        if (question) {

            setDescription(question?.description)
            setTried(question?.tried)
            setLocation(question?.location)
            setQueue(question?.tags?.map(v => ({
                value: v.id,
                label: v.name
            })))
        }
    }, [question])

    const {data: messages} = useQuery(['questions', question?.id, 'messages'], {
        enabled: !!question
    })

    const {data: queues} = useQuery(['courses', parseInt(courseId, 10), 'tags'], {
        placeholderData: []
    })
    const {mutateAsync: updateQuestion} = useWrappedMutation(() => ({
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


    const [description, setDescription] = useState(question?.description);
    const [tried, setTried] = useState(question?.tried);
    const [location, setLocation] = useState(question?.location);
    const [queue, setQueue] = useState(question?.tags?.map(v => ({
        value: v.id,
        label: v.name
    })))

    let title = '';
    let border = '';
    if (question?.question_state.state === "frozen") {
        title = "Frozen";
        border = '4px solid #2185D0';
    } else if (question?.question_state.state === "unresolved") {
        title = "Waiting"
    } else if (question?.question_state.state === "resolving") {
        title = "Resolving"
        border = '4px solid #21BA45';
    } else if (question?.question_state.state === "kicked") {
        title = "Kicked"
    }


    const {register, handleSubmit, control, watch,formState: {errors: formErrors}} = useForm();


    const formFields = watch();

    return (
        <Card style={{border}} className="shadow-sm">
            <Card.Body>
                <div>
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
                    <Form>
                        <div className="mb-2">
                            <label> Queue </label>
                            <Controller
                                defaultValue={question?.tags?.map(v => ({
                                    value: v.id,
                                    label: v.name
                                }))}
                                name="queues"
                                control={control}
                                render={({field}) =>
                                    <Select
                                        className={formErrors?.queues ? "err" : ""}
                                        {...field}
                                        isMulti
                                        options={queues.filter(v => !v.archived).map(v => ({
                                            value: v.id, label: v.name
                                        }))}
                                    />
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
                            <label> Description </label>
                            <Form.Control
                                className={formErrors.description ? "is-invalid" : ""}
                                as='textarea'
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
                            <label> Tried </label>
                            <Form.Control
                                className={formErrors.tried ? "is-invalid" : ""}
                                {...register("tried", {
                                    value: question?.tried,
                                    required: {
                                        value: true,
                                        message: "What you tried is required."
                                    }
                                })}
                                as='textarea'
                            />
                            {formErrors.description && <span className="invalid-feedback d-block">
                                    {formErrors?.tried?.message}
                                </span>}
                        </div>
                        <div className="mb-3">
                            <label> Location </label>
                            <Form.Control
                                as='textarea'
                                className={formErrors.location ? "is-invalid" : ""}
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
                    </Form>
                    <div
                        className="mt-3"
                        style={{
                            display: 'grid',
                            gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
                            columnGap: '10px'
                        }}>
                        <Button variant='success'
                                disabled={(formFields.tried === question?.tried &&
                                    formFields.description === question?.description &&
                                    formFields.location === question?.location &&
                                    formFields.queues.length === queue.length &&
                                    question?.tags?.map(v => v.id).every((v, i) => v === formFields.queues[i].value) &&
                                    formFields.queues.every((v, i) => v.value === question?.tags?.map(v => v.id)[i]))}
                                onClick={handleSubmit(async e => {
                                    await updateQuestion()
                                })}

                        >
                            Change
                        </Button>
                        {question?.question_state.state === "frozen" ? <Button
                            variant='primary'
                            onClick={e => {
                                try {
                                    unfreeze()
                                } catch (e) {

                                }
                            }}>
                            Unfreeze
                        </Button> : null}
                        <Button
                            variant="danger"
                            onClick={async e => {
                                await deleteQuestion()
                            }}
                            load
                        >
                            {deleteLoading ? <Spinner
                                as="span"
                                animation="border"
                                role="status"
                                aria-hidden="true"
                            /> : <>Delete</>}
                        </Button>
                    </div>
                </div>
            </Card.Body>
        </Card>
    )
}