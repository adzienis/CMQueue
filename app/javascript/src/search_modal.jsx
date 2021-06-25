// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, {useEffect, useState} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";
import useWrappedMutation from "./useWrappedMutation";
import CourseCard from "./CourseCard";


const Component = props => {
    const {userId} = props;
    const [open, setOpen] = useState(false);
    const [search, setSearch] = useState('');
    const {
        data,
    } = useQuery(['courses', 'search', '?', `name=${search}`], {
        select: data => {
            if (search === '') return []

            return data.map(v => ({title: v.name, id: v.id}))
        }
    })

    const {data: courses} = useQuery(['users', parseInt(userId, 10), 'enrollments', '?', 'role=student'])

    const {mutate, errors, setErrors} = useWrappedMutation((course_id) => ({
            enrollment: {
                course_id
            }
        }), '/user/enrollments', {}
    )

    useEffect(() => {
        if (!open) setErrors({})
    }, [open])

    let searchResults = null;

    if (data?.length === 0 && search === "") {
        searchResults = null;
    } else if (data?.length === 0 && search !== null && search !== "") {
        searchResults = (
            <ul className="list-group position-relative">
                <li className="list-group-item position-absolute w-100">
                    No courses found by this name
                </li>
            </ul>
        )
    } else if (data?.length > 0) {
        searchResults = data?.map(v => <li
            className="list-group-item w-100"
            style={{cursor: 'pointer'}}
            value={v.id}
            onClick={e => {
                mutate(e.target.value)
            }}
        >
            {v.title}
        </li>)
    }


    return (
        <>
            <div className="modal fade" id="search-modal">
                <div className="modal-dialog modal-dialog-centered modal-lg">
                    <div className="modal-content">
                        <div className="modal-header">
                            <h5 className="modal-title">
                                Course Search
                            </h5>

                            <button type="button" className="btn-close" data-bs-dismiss="modal"
                                    aria-label="Close"></button>
                        </div>
                        <div className="modal-body">
                            <form>
                                <div>
                                    <label className="form-label">Courses</label>
                                    <input className="form-control" type='text' onChange={e => {
                                        setSearch(e.target.value)
                                    }}/>
                                    {
                                        <ul className="list-group position-relative">
                                            <div className="position-absolute w-100">
                                                {searchResults}
                                            </div>

                                        </ul>}
                                </div>
                            </form>
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


const node = document.querySelectorAll('#hello-react')
if (node.length > 0) {

    node.forEach((v) => {
        const data = JSON.parse(v.getAttribute('data'))


        ReactDOM.render(<QueryClientProvider client={window.queryClient}
                                             contextSharing><Component {...data}/></QueryClientProvider>, v)
    })
}

// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#hello-react')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))


            ReactDOM.render(<QueryClientProvider client={window.queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})