import React, {useEffect, useLayoutEffect} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";

const Component = props => {

    const {courseId} = props;

    const {data: count} = useQuery(['courses',
        parseInt(courseId, 10),
        'questions', 'count', '?', 'state=["unresolved", "frozen"]'])

    useLayoutEffect(() => {
        if(typeof count !== "undefined") {
            if(count === 1) {
                document.title = `${count} question`
            } else {
                document.title = `${count} questions`
            }
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

            ReactDOM.render(<QueryClientProvider client={window.queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})