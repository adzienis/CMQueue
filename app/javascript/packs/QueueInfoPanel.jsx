// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";

import queryClient from './queryClientFile'

const Component = props => {

    const {courseId, userId} = props;

    const {data: count} = useQuery(['courses',
        parseInt(courseId, 10),
        'questions', 'count', '?', 'state=["unresolved", "frozen"]'], {
        placeholderData: -1
    })


    const {data: activeTas} = useQuery(
        ['courses', parseInt(courseId, 10), 'activeTAs'], {
            placeholderData: []
        })


    return (
        <div className='mt-3 mb-4 w-100'>
            <div style={{
                display: 'grid',
                gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
                gridGap: '10px'
            }}>
                <div className='card bg-white'>
                    <div className='card-body d-flex flex-row'>
                        <div className='me-3 d-flex justify-content-center align-items-center'>
                            <i className="fas fa-question fa-3x"></i>
                        </div>
                        <div>
                            <div className='card-title mb-1'>
                                <b>
                                    Current Number of Unresolved Questions
                                </b>
                            </div>
                            <div className='card-text'>
                                <p className='h4 text-secondary'>
                                    {count}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
                <div className='card bg-white'>
                    <div className='card-body d-flex flex-row'>
                        <div className='me-3 d-flex justify-content-center align-items-center'>
                            <i className="fas fa-users fa-3x"></i>
                        </div>
                        <div>
                            <div className='card-title mb-1'>
                                <b>
                                    Active TA's
                                </b>
                            </div>
                            <div className='card-text'>
                                <p className='h4'>
                                    {activeTas?.map(v => v.given_name).join(',')}
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#queue-info-panel')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))

            ReactDOM.render(<QueryClientProvider client={queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})