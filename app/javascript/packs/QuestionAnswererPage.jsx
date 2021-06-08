import QuestionExplainer from "./QuestionExplainer";
import {Button, Card} from "react-bootstrap";
import React, {useEffect, useRef, useState} from "react";
import {QueryClientProvider, useQuery, useQueryClient} from "react-query";
import useWrappedMutation from "./useWrappedMutation";
import ReactDOM from "react-dom";
import queryClient from "./queryClientFile";
import QuestionCard from "./QuestionCard";

const Component = props => {
    const {userId, courseId} = props;
    const refq = useRef();

    const [openExplain, setOpenExplain] = useState(false);

    const [selector, setSelector] = useState('question');

    const queryClient = useQueryClient();

    const {
        data: topQuestion,
        isFetching
    } = useQuery(['courses', parseInt(courseId, 10), 'topQuestion', '?', `user_id=${userId}`], {
        onSuccess: async d => {
            if (!d) {
            }
        }
    })

    useEffect(async () => {
        if (topQuestion) {
        } else if (!topQuestion && !isFetching) {
            try {
                await queryClient.prefetchInfiniteQuery(['courses', parseInt(courseId, 10), 'paginatedQuestions'],
                    ({pageParam = 0}) => {
                        return fetch(`/courses/${courseId}/questions?cursor=${pageParam}&` +
                            `state=["frozen", "unresolved"]&course_id=${courseId}`, {
                            headers: {
                                'Accept': 'application/json'
                            }
                        }).then(resp => resp.json()).then(json => {
                            console.log(json)
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
            } catch (e) {

            }

        }
    }, [topQuestion])


    const {data: paginatedPreviousQuestions} = useQuery(
        ['questions', topQuestion?.id, 'paginatedPreviousQuestions'], {
            enabled: !!topQuestion
        })

    const {mutateAsync: handleQuestion, isLoading: handleLoading} = useWrappedMutation(({state}) => ({
        question_state: {
            state,
            user_id: userId,
            question_id: topQuestion.id
        }
    }), '/question_states', {}, {
        onSuccess: async d => {

            Turbo.visit(`/courses/${courseId}/`, {action: 'replace'})
        }
    })

    let elem = null;

    if (selector === 'previousQuestions') {
        elem = (
            <>
                <div style={{
                    display: 'grid',
                    gridTemplateColumns: 'repeat(auto-fit, minmax(350px, 1fr))',
                    columnGap: '20px'
                }}>
                    {paginatedPreviousQuestions?.length > 0 ? (paginatedPreviousQuestions?.map(v => <a
                        href={`/questions/${v.id}`} className='text-decoration-none mb-2'
                        style={{color: 'inherit'}}>
                        <QuestionCard question={v}/>
                    </a>)) : (
                        <div className='alert alert-warning'>
                            No Previous Questions
                        </div>
                    )}
                </div>
            </>
        )
    } else if (selector === 'question') {
        elem = (
            <div className='p-1'>
                <h4>
                    <b>
                        Description
                    </b>
                </h4>
                <span>
                             {topQuestion?.description}
                            </span>
                <h4>
                    <b>
                        What Have They Tried?
                    </b>
                </h4>
                <span>
                                {topQuestion?.tried}
                            </span>
                <h4>
                    <b>
                        Zoom
                    </b>
                </h4>
                <span>
                                {topQuestion?.location}
                            </span>
                <h4>
                    <b>
                        Queues
                    </b>
                </h4>
                <span>
                                {topQuestion?.tags?.map(v => v.name).join(', ')}
                            </span>
            </div>
        )
    }


    return (
        <>
            <QuestionExplainer
                question={topQuestion}
                userId={userId}
                callback={refq.current}
                open={openExplain}
                setOpen={setOpenExplain}
            />
            <Card className='shadow mb-5'>
                <Card.Body>
                    <Card.Title>
                        <div className="d-flex">
                            <h2>
                                {`${topQuestion?.user.given_name} ${topQuestion?.user.family_name}`}
                            </h2>
                            <div className="flex-1"/>
                            <a href={`/courses/${courseId}/questions/${topQuestion?.id}`}>
                                <i className="fas fa-info-circle fa-lg"></i>
                            </a>
                        </div>
                    </Card.Title>
                    <hr/>
                    <div>
                        {elem}
                    </div>
                </Card.Body>
                <Card.Footer>
                    <div style={{
                        display: 'grid',
                        gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
                        columnGap: '5px'
                    }}>
                        <Button variant='success' onClick={() => {
                            try {
                                handleQuestion({
                                    state: 'resolved'
                                })
                            } catch (e) {

                            }
                        }}
                        >
                            Finish Resolving
                        </Button>
                        <Button
                            variant='primary'
                            onClick={() => {
                                try {
                                    refq.current = async () => handleQuestion({
                                        state: 'frozen'
                                    })

                                    setOpenExplain(true)
                                } catch (e) {

                                }
                            }}
                        >
                            Freeze
                        </Button>
                        <Button variant='danger' onClick={() => {
                            try {
                                refq.current = async () => handleQuestion({
                                    state: 'kicked'
                                })

                                setOpenExplain(true)
                            } catch (e) {

                            }
                        }}
                        >
                            Kick
                        </Button>
                        <Button variant='secondary' onClick={() => {
                            try {
                                handleQuestion({
                                    state: 'unresolved'
                                })
                            } catch (e) {

                            }
                        }}
                        >
                            Put Back
                        </Button>
                    </div>
                </Card.Footer>
            </Card>
        </>
    )
}


// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#question-answerer')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))

            ReactDOM.render(<QueryClientProvider client={queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})