import React, {useMemo, useState} from 'react'
import {useMutation, useQuery} from "react-query";
import mutationFn from "./mutationFn";
import useWrappedMutation from "./useWrappedMutation";
import stateEnumMapper from "./stateEnumMapper";
import {Button, Card, Form, Spinner} from "react-bootstrap";


export default function QuestionWaitingModal(props) {

    const {courseId, userId} = props;

    const {data: [question], isLoading, isFetching, refetch} = useQuery(['courses',
        parseInt(courseId, 10),
        'questions', '?', `user_id=${userId}`, 'state=["unresolved", "frozen", "resolving"]'], {
        placeholderData: [], onSuccess: data => {
            const [question] = data;

            setDescription(question?.description)
            setTried(question?.tried)
            setLocation(question?.location)
            setQueue(question?.tags?.map(v => v.id))
        }
    })
    const {data: messages} = useQuery(['questions', question?.id, 'messages'], {
        enabled: !!question
    })

    const {data: queues} = useQuery(['courses', parseInt(courseId, 10), 'tags'], {
        placeholderData: []
    })
    const {mutateAsync: updateQuestion} = useWrappedMutation(() => ({
        question: {
            description,
            tried,
            location,
            tags: queue
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
    const [queue, setQueue] = useState(question?.tags?.map(v => v.id))

    const [header, color] = useMemo(() => {
        if (stateEnumMapper(question?.state) === 'frozen') {
            return ['Frozen', 'blue']
        } else if (stateEnumMapper(question?.state) === 'resolving') {
            return ['Resolving', 'green']
        } else if (stateEnumMapper(question?.state) === 'kicked') {
            return ['Kicked', 'red']
        } else {
            return ['Waiting', 'black']
        }
    }, [question])

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
                            <Form.Label> <b> Description</b> </Form.Label>
                            <Form.Control as='textarea'
                                          rows={3}
                                          value={description}
                                          onChange={e => setDescription(e.target.value)}
                            />

                        </div>
                        <div className="mb-2">
                            <Form.Label><b>Queue</b></Form.Label>
                            <Form.Control as='select' multiple
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
                            <Form.Label> <b>What Have You Tried?</b></Form.Label>
                            <Form.Control
                                as='textarea'
                                rows={3}
                                value={tried}
                                onChange={e => setTried(e.target.value)}
                            />
                        </div>
                        <div className="mb-2">
                            <Form.Label> <b>Zoom</b> </Form.Label>
                            <Form.Control
                                as='textarea'
                                rows="1"
                                value={location}
                                onChange={e => setLocation(e.target.value)}
                            />
                        </div>
                    </Form>
                    <div style={{
                        display: 'grid',
                        gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
                        columnGap: '10px'
                    }}>
                        <Button variant='success'
                                disabled={(tried === question?.tried &&
                                    description === question?.description &&
                                    location === question?.location &&
                                    question?.tags?.map(v => v.id).every((v, i) => v === queue[i]) &&
                                    queue.every((v, i) => v === question?.tags?.map(v => v.id)[i]))}
                                onClick={async e => {
                                    await updateQuestion()
                                }}

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