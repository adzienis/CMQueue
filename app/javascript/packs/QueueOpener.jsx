import React, {useEffect, useState} from 'react';
import useWrappedMutation from "./useWrappedMutation";
import {useQuery} from "react-query";
import {Button} from "react-bootstrap";

export default props => {

    const {userId, courseId} = props;

    const [open, setOpen] = useState(false);
    const {data: openStatus} = useQuery(['courses', parseInt(courseId, 10), 'open_status'])

    const {data: questions} = useQuery(
        ['courses', parseInt(courseId, 10), 'questions', '?', `state=["unresolved"]`], {
            placeholderData: []
        })



    const {mutateAsync, isLoading: queueLoading} = useWrappedMutation(() => ({
        open: {
            status: !openStatus
        }
    }), `/api/courses/${courseId}/open`)

    return (
        <Button onClick={e => {
            try {
                mutateAsync()
            } catch (e) {
            }
        }}
                variant={openStatus ? 'success' : 'danger'}
                className='queue-button w-100'
        >
            {openStatus? "Close Queue" : "Open Queue"}
        </Button>
    )
}