// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useQuery} from "react-query";

import queryClient from './queryClientFile'
import QuestionWaitingModal from "./QuestionWaitingModal";
import QuestionCreator from "./QuestionCreator";

const Component = props => {

    const {courseId, userId} = props;

    const {data: [question], isLoading, isFetching, refetch} = useQuery(['courses',
        parseInt(courseId, 10),
        'questions', '?', `user_id=${userId}`, 'state=["unresolved", "frozen", "resolving"]'], {
        placeholderData: []
    })


    console.log('asdasdlka')


    if (isLoading) return null;


    return (
        <>
            {question ? <QuestionWaitingModal courseId={courseId} userId={userId}/> :
                <QuestionCreator courseId={courseId} userId={userId}/>}
        </>
    )

}

// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#student-queue-view')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))

            ReactDOM.render(<QueryClientProvider client={queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})