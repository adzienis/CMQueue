// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React, {useMemo} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider, useInfiniteQuery} from "react-query";

import queryClient from './queryClientFile'
import QuestionCard from "./QuestionCard";
import {Button} from "react-bootstrap";

const Component = props => {

    const {courseId, userId} = props;


    const {data, fetchNextPage, hasNextPage} =
        useInfiniteQuery(['courses', parseInt(courseId, 10), 'paginatedQuestions'],
            ({pageParam = -1}) => {
                return fetch(`/courses/${courseId}/questions?cursor=${pageParam}&` +
                    `state=["frozen", "unresolved"]&course_id=${courseId}`, {
                    headers: {
                        'Accept': 'application/json'
                    }
                }).then(resp => resp.json()).then(json => {
                    return {
                        cursor: json.cursor?.id,
                        data: json.data
                    }
                })
            }, {
                getNextPageParam: (lastPage, pages) => {
                    return lastPage.cursor
                }
            })

    const flattenedQuestions = useMemo(() => {
        return data?.pages.map(v => v.data).flat()
    }, [data])


    return (

        <div>
            <div className='mb-4'>
                <h1 className='mb-3'>
                    Questions
                </h1>
                {flattenedQuestions?.length > 0 ? flattenedQuestions?.map(v => (

                    <QuestionCard key={v.id}
                                  question={v}
                                  userId={userId}
                                  courseId={courseId}
                    />
                )) : (
                    <div className='alert alert-warning border'>
                        No Questions
                    </div>
                )}
                <div className='mt-4'>
                    <Button onClick={async () => {
                        await fetchNextPage()
                    }}
                            disabled={!hasNextPage}
                    >
                        Load More Questions
                    </Button>
                </div>
            </div>
        </div>
    )

}

// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#ta-queue-view')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))

            ReactDOM.render(<QueryClientProvider client={queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})