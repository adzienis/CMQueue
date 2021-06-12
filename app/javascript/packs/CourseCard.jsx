import useWrappedMutation from "./useWrappedMutation";
import React from 'react';

export default props => {

    const {course} = props;

    const {mutateAsync: deleteEnrollment} = useWrappedMutation(() => ({}), `/enrollments/${course.id}`, {
        method: 'DELETE'
    })

    return (
        <a  href={`/courses/${course?.id}`} className='card shadow-sm text-decoration-none hover-container' style={{ color: 'inherit'}}>
            <div className="card-body">
                <div className="card-title">
                    <div style={{display: 'flex'}}>
                            <span style={{flex: 1}}>
                                Go to <b>
                                {course?.name}
                            </b>
                            </span>
                        <i className="fas fa-times fa-lg" onClick={e => {
                            e.preventDefault()
                            try {
                                deleteEnrollment()
                            } catch (e) {

                            }
                        }}/>
                    </div>
                </div>
            </div>
        </a>
    )
}