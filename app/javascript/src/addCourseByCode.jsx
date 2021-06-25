import React, {useState} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";

import queryClient from './queryClientFile'
import useWrappedMutation from "./useWrappedMutation";
import CourseCard from "./CourseCard";


const Component = props => {
    const {userId} = props;


    const {data: courses} = useQuery(['users', parseInt(userId, 10), 'enrollments', '?', 'role=ta'])
    const {data: instructor_courses} = useQuery(['users', parseInt(userId, 10), 'enrollments', '?', 'role=instructor'])

    const {mutateAsync: createEnrollment, errors} = useWrappedMutation(() => ({
        enrollment: {
            code,
        }
    }), `/user/enrollments`, {
        method: 'POST'
    })
    const [code, setCode] = useState('');
    const [open, setOpen] = useState(false)

    console.log(courses?.concat(instructor_courses))


    return <>
        <div className="modal fade" id="course-code-modal">
            <div className="modal-dialog modal-dialog-centered modal-lg">
                <div className="modal-content">
                    <div className="modal-header">
                        <h5 className="modal-title">
                            Add Course By Role Code
                        </h5>
                        <button type="button" className="btn-close" data-bs-dismiss="modal"
                                aria-label="Close"></button>
                    </div>
                    <div className="modal-body">
                        <form>
                            <div className="mb-2">
                                <label className="form-label"> Role Code </label>
                                <input
                                    className="form-control"
                                    value={code}
                                    onChange={e => setCode(e.target.value)}
                                />

                            </div>
                            <button className="btn btn-primary" onClick={e => {
                                try {
                                    createEnrollment();
                                } catch (e) {

                                }
                            }}>
                                Submit
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <div style={{display: 'grid', gridTemplateColumns: '1fr', rowGap: '1rem'}}>
            <a
                href=""
                className="card shadow-sm hover-container"
                data-bs-toggle="modal" data-bs-target="#course-code-modal"
            >
                <div className="card-body" style={{display: 'flex', justifyContent: 'center'}}>
                    <i className="fas fa-plus fa-2x"/>
                </div>
            </a>
            {(courses && instructor_courses) ? courses.concat(instructor_courses).map(v => <CourseCard course={v}/>) : null}
        </div>
    </>
}

// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#add-course-by-code')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))


            ReactDOM.render(<QueryClientProvider client={queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})