// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, {useEffect, useState} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";
import useWrappedMutation from "./useWrappedMutation";
import queryClient from './queryClientFile'
import CourseCard from "./CourseCard";
import {Form} from "react-bootstrap";


const Hello = props => {
    const [open, setOpen] = useState(false);
    const [search, setSearch] = useState(null);
    const {
        data,
    } = useQuery(['courses', 'search', '?', `name=${search}`], {
        select: data => data.map(v => ({title: v.name, id: v.id}))
    })

    const {data: courses} = useQuery(['user', 'enrollments', '?', 'role=student'])

    const {mutate, errors, setErrors} = useWrappedMutation((course_id) => ({
            enrollment: {
                course_id
            }
        }), '/user/enrollments', {}
    )

    useEffect(() => {
        if (!open) setErrors({})
    }, [open])


    return (
        <>
            <div className="modal fade" id="search-modal">
                <div className="modal-dialog modal-dialog-centered">
                    <div className="modal-content">
                        <div className="modal-header">
                            <h5 className="modal-title">
                                Course Search
                            </h5>
                        </div>
                        <div className="modal-body">
                            <Form>
                                <Form.Group>
                                    <label>Courses</label>
                                    <Form.Control type='text' onChange={e => {
                                        setSearch(e.target.value)
                                    }}/>
                                    {(typeof data?.length !== "undefined" && data?.length !== 0) ?
                                        <Form.Control as='select' multiple='multiple' htmlSize={data?.length}>
                                            {data?.map(v => <option
                                                value={v.id}
                                                onClick={e => {
                                                    mutate(e.target.value)
                                                }}
                                            >
                                                {v.title}
                                            </option>)}
                                        </Form.Control> : null}
                                </Form.Group>
                            </Form>
                        </div>
                    </div>
                </div>
            </div>

            <div style={{display: 'grid', gridTemplateColumns: '1fr', rowGap: '1rem'}}>
                <a
                    href=""
                    className="card shadow-sm hover-container"
                    data-bs-toggle="modal" data-bs-target="#search-modal"
                >
                    <div className="card-body" style={{display: 'flex', justifyContent: 'center'}}>
                        <i className="fas fa-plus fa-2x"/>
                    </div>
                </a>
                {courses?.map(v => <CourseCard course={v}/>)}
            </div>
        </>)
}


// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#hello-react')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))

            ReactDOM.render(<QueryClientProvider client={queryClient} contextSharing><Hello/></QueryClientProvider>, v)
        })
    }
})

/*

    useEffect(async () => {
        if (search != null) {
            const data = await queryClient.fetchQuery(['courseSearch', search], () => fetch(`/courses/search?name=${search}`, {
                headers: {
                    'Accept': 'application/json'
                }
            }).then(resp => resp.json()).then(json => json.map(v => ({title: v.name, id: v.id}))))

            setData(data)
        }
    }, [search])


    console.log('heeeeeeeeeeeeeeeeeeeeeer')

 */