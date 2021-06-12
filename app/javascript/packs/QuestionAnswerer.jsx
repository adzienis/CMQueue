import React from 'react';
import useWrappedMutation from "./useWrappedMutation";
import {useQuery, useQueryClient} from "react-query";
import {Button, Spinner} from "react-bootstrap";
import DelayedSpinner from "./DelayedSpinner";

export default props => {

    const {userId, courseId} = props;

    const {data: topQuestion} = useQuery(['courses', parseInt(courseId, 10), 'topQuestion', '?', `user_id=${userId}`], {
        onSuccess: d => {
            if (d) {
                Turbo.visit(`/courses/${courseId}/answer`)
            }
        }
    })

    const {data: questions} = useQuery(
        ['courses', parseInt(courseId, 10), 'questions', '?', `state=["unresolved"]`], {
            placeholderData: []
        })


    const {mutateAsync, isLoading: answerLoading} = useWrappedMutation(() => ({
        answer: {
            state: 'resolving',
            user_id: userId
        }
    }), `/api/courses/${courseId}/answer`, {
        onSuccess: d => {
            if (d) {
                Turbo.visit(`/courses/${courseId}/answer`)

            }
        }
    })

    return (<Button onClick={async e => {
            try {
                await mutateAsync()
            } catch (e) {
            }
        }}
                    variant={questions?.length > 0 ? 'success' : 'danger'}
                    disabled={!questions?.length}
                    fluid
                    loading={answerLoading}
                    className='queue-button mr-3 w-100'
        >
            <DelayedSpinner loading={answerLoading}>
                Answer a Question
            </DelayedSpinner>
        </Button>
    )
}