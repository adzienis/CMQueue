// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, {useEffect} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery, useQueryClient} from "react-query";

import queryClient from './queryClientFile'

const Component = props => {

    const {userId} = props;
    const queryClient = useQueryClient()

    const {data: studentCourses} = useQuery(['user', 'enrollments', '?', 'role=student'], {
        placeholderData: []
    })
    const {data: taCourses} = useQuery(['user', 'enrollments', '?', 'role=ta'], {
        placeholderData: []
    })

    useEffect(() => {
        studentCourses.forEach(v => {
            queryClient.prefetchQuery(['courses', parseInt(v.id, 10), 'open']);
            queryClient.prefetchQuery(['courses',
                parseInt(v.id, 10),
                'questions', 'count', '?', 'state=["unresolved", "frozen"]'])
            queryClient.prefetchQuery(['courses', parseInt(v.id, 10), 'activeTAs'])
        })
    }, [studentCourses])


    useEffect(() => {

        taCourses.forEach(v => {
            queryClient.prefetchQuery(['courses', parseInt(v.id, 10), 'open']);
            queryClient.prefetchQuery(['courses', parseInt(v.id, 10), 'questions', '?', `state=["unresolved"]`])
            queryClient.prefetchQuery(['courses',
                parseInt(v.id, 10),
                'questions', 'count', '?', 'state=["unresolved", "frozen"]'])
            queryClient.prefetchQuery(['courses', parseInt(v.id, 10), 'activeTAs'])
            queryClient.prefetchInfiniteQuery(['courses', parseInt(v.id, 10), 'paginatedQuestions'],
                ({pageParam = -1}) => {
                    return fetch(`/courses/${v.id}/questions?cursor=${pageParam}&` +
                        `state=["frozen", "unresolved"]&course_id=${v.id}`, {
                        headers: {
                            'Accept': 'application/json'
                        }
                    }).then(resp => resp.json()).then(json => {
                        return {
                            cursor: json.cursor?.id,
                            data: json.data
                        }
                    })
                })
        })
    }, [taCourses])

    return null;
}

// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#prefetcher')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))


            ReactDOM.render(<QueryClientProvider client={queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})