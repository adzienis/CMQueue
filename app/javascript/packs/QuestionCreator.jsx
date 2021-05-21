import React, {useState} from 'react';
import {useQuery} from "react-query";
import useWrappedMutation from "./useWrappedMutation";
import {Button, Form} from "react-bootstrap";

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

    const {data: openStatus} = useQuery(['courses', parseInt(courseId, 10), 'open'])


    const {mutateAsync: createQuestion, isLoading, errors} = useWrappedMutation(() => ({
        question: {
            description,
            tried,
            location,
            course_id: courseId,
            user_id: userId,
            tags: queue
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
                <div className='card'>
                    <div className='card-body'>
                        <h1>
                            Create a Question
                        </h1>
                        <Form>

                            <div className="mb-2">
                                <label> Queue </label>
                                <Form.Control
                                    as='select'
                                    multiple
                                    placeholder="Select a Queue"
                                    value={queue}
                                    onChange={(e, d) => {
                                        console.log()
                                        setQueue([...e.target.options].filter(v => v.selected).map(v => v.value))
                                    }
                                    }

                                >
                                    {queues.filter(v => !v.archived).map(v => (<option key={v.id} value={v.id}>
                                        {v.name}
                                    </option>))}
                                </Form.Control>
                            </div>
                            <div className="mb-2">
                                <label> Description </label>
                                <Form.Control
                                    as='textarea'
                                    value={description}
                                    onChange={e => setDescription(e.target.value)}
                                    error={errors.description ? {
                                        content: errors.description?.join(' and')
                                    } : null}

                                />
                            </div>
                            <div className="mb-2">
                                <label> Tried </label>
                                <Form.Control
                                    as='textarea'
                                    value={tried}
                                    onChange={e => setTried(e.target.value)}
                                    error={errors.tried ? {
                                        content: errors.tried?.join(' and')
                                    } : null}
                                />
                            </div>
                            <div className="mb-2">
                                <label> Location </label>
                                <Form.Control
                                    as='textarea'
                                    value={location}
                                    onChange={e => setLocation(e.target.value)}
                                    error={errors.location ? {
                                        content: errors.location?.join(' and')
                                    } : null}
                                />
                            </div>
                            <Button onClick={e => {
                                try {
                                    createQuestion();
                                } catch (e) {

                                }
                            }}>
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