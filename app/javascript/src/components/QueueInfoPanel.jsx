import React from "react";
import {useQuery} from "react-query";
import QueueInfoItem from "./QueueInfoItem";
import TALog from "./TALog";
import QuestionPosition from "./QuestionPosition";

export default (props) => {
    const {courseId, userId, enrollment} = props;

    const {data: d} = useQuery(['courses', parseInt(courseId, 10), 'answer_time'])

    const {
        data: [question],
        isLoading,
        isFetching,
        refetch,
    } = useQuery(
        [
            "courses",
            parseInt(courseId, 10),
            "questions",
            "?",
            `user_id=${userId}`,
            'state=["unresolved", "frozen", "resolving"]',
        ],
        {
            placeholderData: [null],
        }
    );

    const {data: openStatus, isLoading: openLoading} = useQuery([
        "courses",
        parseInt(courseId, 10),
        "open_status",
    ]);


    const {data: count, isLoading: countLoading} = useQuery([
        "courses",
        parseInt(courseId, 10),
        "questions",
        "count",
        "?",
        `state=${JSON.stringify(["unresolved", "frozen"])}`,
    ]);

    const {data: activeTas, isLoading: activeLoading} = useQuery([
        "courses",
        parseInt(courseId, 10),
        "activeTAs",
    ]);


    return (
        <div className="accordion mt-3 mb-4 w-100">
            <div className="accordion-item">
                <h2 className="accordion-header">
                    <button className="accordion-button" type="button" data-bs-toggle="collapse"
                            data-bs-target="#info-collapse">
                        <b>Queue Information</b>
                    </button>
                </h2>
                <div id="info-collapse" className="accordion-collapse collapse show">
                    <div className="accordion-body">
                        <div
                            className="mb-2"
                            style={{
                                display: "grid",
                                gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))",
                                gridGap: "10px",
                            }}
                        >
                            <QueueInfoItem
                                title={"Queue Status"}
                                icon={
                                    <div className="me-3 d-flex justify-content-center align-items-center">
                                        <i className="fas fa-question fa-2x"/>
                                    </div>
                                }
                                loading={openLoading}
                                value={
                                    openStatus ? (
                                        <span className="text-success"> Open </span>
                                    ) : (
                                        <span className="text-danger"> Closed </span>
                                    )
                                }
                            />
                            <QueueInfoItem
                                title={"Unresolved Questions"}
                                icon={
                                    <div className="me-3 d-flex justify-content-center align-items-center">
                                        <i className="fas fa-question fa-2x"/>
                                    </div>
                                }
                                loading={countLoading}
                                value={count}
                            />
                            {((enrollment?.role.name === "student") && question) ? (
                                <QuestionPosition question={question} courseId={courseId}/>
                            ) : null}
                        </div>
                        <QueueInfoItem
                            title={"Active TA's"}
                            loading={activeLoading}
                            icon={
                                <div className="me-3 d-flex justify-content-center align-items-center">
                                    <i className="fas fa-users fa-3x"/>
                                </div>
                            }
                            value={activeTas?.map((v) => v.given_name).join(",")}
                            footer={enrollment?.role.name !== "student" ? (
                                <div className="accordion" id="accordion-ta-log">
                                    <div className="accordion-item">
                                        <h2 className="accordion-header">
                                            <button className="accordion-button collapsed" type="button"
                                                    data-bs-toggle="collapse"
                                                    data-bs-target="#collapse-ta-log">
                                                <b>TA Log</b>
                                            </button>
                                        </h2>
                                        <div id="collapse-ta-log" className="accordion-collapse collapse"
                                             data-bs-parent="#accordion-ta-log">
                                            <div className="accordion-body p-0">
                                                <TALog height={300} limited courseId={courseId}/>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            ) : null}
                        />

                    </div>
                </div>
            </div>


        </div>
    );
};
