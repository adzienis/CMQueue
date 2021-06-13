import React, {useState} from 'react';
import {useQuery} from "react-query";
import useWrappedMutation from "./useWrappedMutation";
import {Button, Form} from "react-bootstrap";
import Select from "react-select";
import {Controller, useForm} from "react-hook-form";

export default props => {

    const {userId, courseId} = props;

    const [queue, setQueue] = useState([]);
    const [description, setDescription] = useState('');
    const [tried, setTried] = useState('');
    const [location, setLocation] = useState('');
    const [open, setOpen] = useState(false);

    const {data: queues} = useQuery(['courses', parseInt(courseId, 10), 'tags'], {
        placeholderData: []
    })

    const {data: openStatus} = useQuery(['courses', parseInt(courseId, 10), 'open_status'])


    const {register, handleSubmit, control, formState: {errors: formErrors}} = useForm();


    const {mutateAsync: createQuestion, isLoading, errors} = useWrappedMutation((data) => ({
        question: {
            description: data.description,
            tried: data.tried,
            location: data.location,
            course_id: courseId,
            user_id: userId,
            tags: data.queues.map(v => v.value)
        }
    }), '/questions', {}, {
        onSuccess: data => {
            setOpen(false);
            setLocation('')
            setTried('')
            setDescription('')
            setQueue([]);
        }
    })

    return <>
        {openStatus ?
            <>
                <div className='card shadow-sm'>
                    <div className='card-body'>
                        <h1>
                            Ask a Question
                        </h1>
                        <Form>
                            <div className="mb-2">
                                <label> Queue </label>
                                <Controller
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
                                        required: {
                                            value: true,
                                            message: "Description is required."
                                        }
                                    })}
                                />
                                {formErrors.description && <span className="invalid-feedback d-block">
                                    {formErrors?.description?.message}
                                </span> }
                            </div>
                            <div className="mb-2">
                                <label> Tried </label>
                                <Form.Control
                                    className={formErrors.tried ? "is-invalid" : ""}
                                    {...register("tried", {
                                        required: {
                                            value: true,
                                            message: "What you tried is required."
                                        }
                                    })}
                                    as='textarea'
                                />
                                {formErrors.description && <span className="invalid-feedback d-block">
                                    {formErrors?.tried?.message}
                                </span> }
                            </div>
                            <div className="mb-3">
                                <label> Location </label>
                                <Form.Control
                                    as='textarea'
                                    className={formErrors.location ? "is-invalid" : ""}
                                    {...register("location", {
                                        required: {
                                            value: true,
                                            message: "Location is required."
                                        }
                                    })}
                                />
                                {formErrors.description && <span className="invalid-feedback d-block">
                                    {formErrors?.location?.message}
                                </span> }
                            </div>
                            <Button onClick={handleSubmit(data => {
                                console.log(data)
                                try {
                                    createQuestion(data);
                                } catch (e) {

                                }
                            })}>
                                Submit
                            </Button>

                        </Form>
                    </div>
                </div>
            </>
            :
            <div className='alert alert-danger'>
                <div className='alert-heading'>
                    Queue is Closed
                </div>
            </div>}
    </>
}