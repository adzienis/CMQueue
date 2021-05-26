// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, {useState} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";

import queryClient from './queryClientFile'
import useWrappedMutation from "./useWrappedMutation";
import CourseCard from "./CourseCard";
import {Button, Form} from "react-bootstrap";


const Component = props => {


    const {data: courses} = useQuery(['user', 'enrollments', '?', 'role=ta'])

    const {mutateAsync: createEnrollment, errors} = useWrappedMutation(() => ({
        enrollment: {
            code,
        }
    }), `/user/enrollments`, {
        method: 'POST'
    })
    const [code, setCode] = useState('');
    const [open, setOpen] = useState(false)


    return <>
        <div className="modal fade" id="course-code-modal">
            <div className="modal-dialog modal-dialog-centered">
                <div className="modal-content">
                    <div className="modal-header">
                        <h5 className="modal-title">
                            Add Course By Role Code
                        </h5>
                    </div>
                    <div className="modal-body">
                        <Form>
                            <div className="mb-2">
                                <label> Role Code </label>
                                <Form.Control
                                    as='input'
                                    rows={3}
                                    value={code}
                                    onChange={e => setCode(e.target.value)}
                                />

                            </div>
                            <Button onClick={e => {
                                try {
                                    createEnrollment();
                                } catch (e) {

                                }
                            }}>
                                Submit
                            </Button>
                        </Form>
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
            {courses?.map(v => <CourseCard course={v}/>)}
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