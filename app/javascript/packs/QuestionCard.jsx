import React from 'react'
import useWrappedMutation from "./useWrappedMutation";
import {useQuery} from "react-query";
import {Button, Card} from "react-bootstrap";

export default props => {

    const {courseId, userId, question} = props;

    const state = question?.question_state.state


    const {mutateAsync: unfreeze, isLoading: frozenLoading} = useWrappedMutation(() => ({
        question_state: {
            state: 'unresolved',
            user_id: userId,
            question_id: question.id
        }
    }), '/question_states')

    const {data: paginatedPreviousQuestions} = useQuery(
        ['questions', question?.id, 'paginatedPreviousQuestions'])

    let statusText = ''
    let statusColor = 'black';

    if (state === 'frozen') {
        statusText = 'Frozen since ';
        statusColor = '#2185D0'
    } else if (state === 'unresolved') {
        statusText = 'Waiting since '
    } else if (state === 'resolved') {
        statusText = 'Resolved at '
    } else if (state === 'kicked') {
        statusText = "Kicked at "
    }


    return (

        <Card
            fluid style={{border: state === "frozen" ? '2px solid #2185D0' : ''}}
            className='mb-2 shadow-sm'
        >
            <Card.Body>
                <Card.Title>

                    {question?.user ? <>
                        <b>
                            {question?.user?.given_name}
                        </b>
                        <br/></> : null}
                    <div style={{color: '#2185D0'}}>
                        {state !== 'unresolved' ?
                            <small>
                                {statusText}
                                <b>
                                    {new Date(question.updated_at).toLocaleTimeString()}
                                </b>
                            </small> :
                            <small>
                                {statusText}
                                <b>
                                    {new Date(question.created_at).toLocaleTimeString()}
                                </b>
                            </small>}
                    </div>

                </Card.Title>
                <Card.Text className='elipsis'>
                    {question.description}
                </Card.Text>
            </Card.Body>
            <Card.Footer>
                <div className="d-flex">
                    {state === "frozen" ? (
                        <div className="me-2">
                            <Button  color='blue' style={{opacity: 1}} onClick={e => {
                                e.preventDefault()
                                e.stopPropagation()
                                unfreeze()
                            }}
                                     loading={frozenLoading}
                            >
                                Unfreeze
                            </Button>
                        </div>
                    ) : null}
                    <div className="d-flex align-items-center">
                        <a href={`/courses/${courseId}/questions/${question?.id}`} className='text-decoration-none'
                           style={{color: 'inherit'}}>
                            <i className="fas fa-info-circle fa-lg"></i>
                        </a>
                    </div>
                </div>
            </Card.Footer>
        </Card>
    )

}
