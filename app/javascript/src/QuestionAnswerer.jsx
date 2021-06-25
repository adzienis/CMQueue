import React, {useState} from 'react';
import useWrappedMutation from "./useWrappedMutation";
import {useQuery} from "react-query";

export default props => {

    const {userId, courseId} = props;

    const [loading, setLoading] = useState(false)

    const {data: topQuestion} = useQuery(['courses', parseInt(courseId, 10), 'topQuestion', '?', `user_id=${userId}`])


    const {data: questions, isLoading: questionsLoading} = useQuery(
        ['courses', parseInt(courseId, 10), 'questions', '?', `state=["unresolved"]`])


    const {mutate: mutateAsync, isLoading: answerLoading} = useWrappedMutation(() => ({
        answer: {
            state: 'resolving',
            user_id: userId
        }
    }), `/api/courses/${courseId}/answer`, {}, {
        onSuccess: async d => {
            setLoading(true);
            if (d) {
                await window.queryClient.prefetchQuery(['courses', parseInt(courseId, 10), 'topQuestion', '?', `user_id=${userId}`])
                Turbo.visit(`/courses/${courseId}/answer`)
            }
        }
    })

    return (<button onClick={e => {
            try {
                mutateAsync()
            } catch (e) {
            }
        }}
                    disabled={!questions?.length}
                    className={`btn queue-button mr-3 w-100 btn-${questions?.length > 0 ? 'success' : ((questionsLoading && !answerLoading) ? "secondary" : 'danger')}`}
        >{
            (topQuestion || questionsLoading) ? (
                <div className="spinner-border" role="status">
                    <span className="visually-hidden">Loading...</span>
                </div>
            ) : <span> Answer a Question </span>
        }
        </button>
    )
}