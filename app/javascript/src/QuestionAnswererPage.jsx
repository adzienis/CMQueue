import QuestionExplainer from "./QuestionExplainer";
import React, {useRef, useState} from "react";
import {QueryClientProvider, useQuery} from "react-query";
import useWrappedMutation from "./useWrappedMutation";
import ReactDOM from "react-dom";

import modal from 'bootstrap/js/dist/modal'

const Component = props => {
    const {userId, courseId} = props;
    const refq = useRef();

    const [openExplain, setOpenExplain] = useState(false);

    const {
        data: topQuestion
    } = useQuery(['courses', parseInt(courseId, 10), 'topQuestion', '?', `user_id=${userId}`], {
        onSuccess: async d => {
            if (!d) {
                Turbo.visit(`/courses/${courseId}/`)
            }
        }
    })

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
    }), '/question_states')

    if (!topQuestion) return (
        <div className="card shadow" style={{height: '600px'}}>
            <div className="card-body h-100">
                <div className="w-100 d-flex justify-content-center align-items-center h-100">
                    <div className="spinner-border" role="status">
                        <span className="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
    )


    return (
        <>
            <QuestionExplainer
                question={topQuestion}
                userId={userId}
                callback={refq.current}
                open={openExplain}
                setOpen={setOpenExplain}
            />
            <div className='card shadow mb-5' style={{height: '600px'}}>
                <div className="card-body">
                    <div className="card-title">
                        <div className="d-flex">
                            <h2>
                                {`${topQuestion?.user?.given_name} ${topQuestion?.user?.family_name}`}
                            </h2>
                            <div className="flex-1"/>
                            <a href={`/courses/${courseId}/questions/${topQuestion?.id}`}>
                                More info{' '}
                                <i className="fas fa-info-circle fa-lg"></i>
                            </a>
                        </div>
                    </div>
                    <hr/>
                    <div>

                        <div className='p-1'>
                            <div className="mb-2">
                                <h4>
                                    <b>
                                        Description
                                    </b>
                                </h4>
                                <span>
                        {topQuestion?.description}
                    </span>
                            </div>
                            <div className="mb-2">
                                <h4>
                                    <b>
                                        What Have They Tried?
                                    </b>
                                </h4>
                                <span>
                        {topQuestion?.tried}
                    </span>
                            </div>
                            <div className="mb-2">
                                <h4>
                                    <b>
                                        Zoom
                                    </b>
                                </h4>
                                <span>
                        {topQuestion?.location}
                    </span>
                            </div>
                            <div className="mb-2">
                                <h4>
                                    <b>
                                        Queues
                                    </b>
                                </h4>
                                <span>
                        {topQuestion?.tags?.map(v =>
                            <a href={`/courses/${courseId}/tags/${v.id}`}>
                                <b>{v.name}</b>
                            </a>
                        )}
                    </span>
                            </div>
                        </div>
                    </div>
                </div>
                <div className="card-footer">
                    <div style={{
                        display: 'grid',
                        gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))',
                        rowGap: '5px',
                        columnGap: '5px'
                    }}>
                        <button className="btn btn-success" onClick={() => {
                            try {
                                handleQuestion({
                                    state: 'resolved'
                                })
                            } catch (e) {

                            }
                        }}
                        >
                            Finish Resolving
                        </button>
                        <button className="btn btn-primary"
                                onClick={() => {
                                    try {
                                        const m = new modal(document.getElementById("exampleModal"), {});
                                        m.show();
                                        refq.current = async () => handleQuestion({
                                            state: 'frozen'
                                        })

                                        setOpenExplain(true)
                                    } catch (e) {

                                    }
                                }}
                        >
                            Freeze
                        </button>
                        <button className="btn btn-danger" onClick={() => {
                            try {

                                const m = new modal(document.getElementById("exampleModal"), {});
                                m.show();

                                refq.current = async () => handleQuestion({
                                    state: 'kicked'
                                })

                                setOpenExplain(true)
                            } catch (e) {

                            }
                        }}
                        >
                            Kick
                        </button>
                        <button className="btn btn-secondary" onClick={() => {
                            try {
                                handleQuestion({
                                    state: 'unresolved'
                                })
                            } catch (e) {

                            }
                        }}
                        >
                            Put Back
                        </button>
                    </div>
                </div>
            </div>
        </>
    )
}

// Render component with data
document.addEventListener('turbo:load', (e) => {

    const node = document.querySelectorAll('#question-answerer')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))

            ReactDOM.render(<QueryClientProvider client={window.queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})