// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, {useState} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";

import queryClient from './queryClientFile'
import useWrappedMutation from "./useWrappedMutation";
import CourseCard from "./CourseCard";
import {Button, Form, Modal} from "react-bootstrap";


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


    return <> <Modal show={open} onHide={() => setOpen(false)}>
        <Modal.Title>
            Add Course By Role Code
        </Modal.Title>
        <Modal.Body>
            <Form>
                <Form.Group>
                    <label> Role Code </label>
                    <Form.Control
                        as='input'
                        rows={3}
                        value={code}
                        onChange={e => setCode(e.target.value)}
                    />

                </Form.Group>
                <Button onClick={e => {
                    try {
                        createEnrollment();
                    } catch (e) {

                    }
                }}>
                    Submit
                </Button>
            </Form>
        </Modal.Body>
    </Modal>

        <div style={{display: 'grid', gridTemplateColumns: '1fr', rowGap: '1rem'}}>
            <a
                href=""
                className="card shadow-sm hover-container"
                onClick={(e) => {
                    e.preventDefault();
                    setOpen(true)
                }
                }
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