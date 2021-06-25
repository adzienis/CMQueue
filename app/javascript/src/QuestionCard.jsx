import React from 'react'
import useWrappedMutation from "./useWrappedMutation";
import {useQuery} from "react-query";

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

        <div
            style={{border: state === "frozen" ? '2px solid #2185D0' : ''}}
            className='card mb-2 shadow-sm'
        >
            <div className="card-body">
                <div className="card-title">

                    {question?.user ? <>
                        <b>
                            {question?.user?.given_name}
                        </b>
                        <br/></> : null}
                    <div style={{color: '#2185D0'}}>
                        {state !== 'unresolved' ?
                            <span>
                                {statusText}
                                <b>
                                    {new Date(question.updated_at).toLocaleTimeString()}
                                </b>
                            </span> :
                            <span>
                                {statusText}
                                <b>
                                    {new Date(question.created_at).toLocaleTimeString()}
                                </b>
                            </span>}
                    </div>

                </div>
                <div className='card-text elipsis'>
                    {question.description}
                </div>
            </div>
            <div className="card-footer">
                <div className="d-flex">
                    {state === "frozen" ? (
                        <div className="me-2">
                            <button className="btn btn-primary" style={{backgroundColor: "rgb(33, 133, 208)"}}
                                    onClick={e => {
                                        e.preventDefault()
                                        e.stopPropagation()
                                        unfreeze()
                                    }}
                                    loading={frozenLoading}
                            >
                                Unfreeze
                            </button>
                        </div>
                    ) : null}
                    <div className="d-flex align-items-center">
                        <a href={`/courses/${courseId}/questions/${question?.id}`} className='text-decoration-none'
                           style={{color: 'inherit'}}>
                            More info{' '}
                            <i className="fas fa-info-circle fa-lg"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    )

}
