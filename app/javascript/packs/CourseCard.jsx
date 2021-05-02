import React from 'react';
import useWrappedMutation from "./useWrappedMutation";
import {Card} from "react-bootstrap";

export default props => {

    const {course} = props;

    const {mutateAsync: deleteEnrollment} = useWrappedMutation(() => ({}), `/enrollments/${course.id}`, {
        method: 'DELETE'
    })

    return (
        <Card as='a' href={`/courses/${course?.id}`} className='shadow-sm text-decoration-none hover-container' style={{ color: 'inherit'}}>
            <Card.Body>
                <Card.Title>
                    <div style={{display: 'flex'}}>
                            <span style={{flex: 1}}>
                                {course?.name}
                            </span>
                        <i className="fas fa-times fa-lg" onClick={e => {
                            e.preventDefault()
                            try {
                                deleteEnrollment()
                            } catch (e) {

                            }
                        }}/>
                    </div>
                </Card.Title>
            </Card.Body>
        </Card>
    )
}