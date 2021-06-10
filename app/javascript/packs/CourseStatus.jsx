// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, {useEffect, useLayoutEffect} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";

import queryClient from './queryClientFile'

const Component = props => {

    const {courseId} = props;

    const {data: count} = useQuery(['courses',
        parseInt(courseId, 10),
        'questions', 'count', '?', 'state=["unresolved", "frozen"]'], {
        placeholderData: -1
    })

    useLayoutEffect(() => {
        if(count === 1) {
            document.title = `${count} question`
        } else {
            document.title = `${count} questions`
        }
    }, [count])

    return null;
}

// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#course-status')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))

            ReactDOM.render(<QueryClientProvider client={queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})