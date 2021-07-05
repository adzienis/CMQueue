import React from "react";
import {useQuery} from "react-query";
import QueueInfoItem from "./QueueInfoItem";
import TALog from "./TALog";

export default (props) => {
    const {courseId, userId, enrollment} = props;

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

    const {data: position, isLoading: positionLoading} = useQuery(
        [
            "courses",
            parseInt(courseId, 10),
            "questions",
            "position",
            "?",
            `question_id=${question?.id}`,
            `state=["unresolved", "frozen"]`,
        ],
        {
            enabled: !!question,
        }
    );

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
        <div className="mt-3 mb-4 w-100">
            <div
                className="mb-2"
                style={{
                    display: "grid",
                    gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
                    gridGap: "10px",
                }}
            >
                <QueueInfoItem
                    title={"Queue Status"}
                    icon={
                        <div className="me-3 d-flex justify-content-center align-items-center">
                            <i className="fas fa-question fa-3x"></i>
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
                    title={"Number of Unresolved Questions"}
                    icon={
                        <div className="me-3 d-flex justify-content-center align-items-center">
                            <i className="fas fa-question fa-3x"></i>
                        </div>
                    }
                    loading={countLoading}
                    value={count}
                />
                {enrollment?.role.name === "student" ? (
                    <QueueInfoItem
                        title={"Your Position on Queue"}
                        loading={positionLoading}
                        icon={
                            <div className="me-3 d-flex justify-content-center align-items-center">
                                <i className="fas fa-map-marker-alt fa-3x"></i>
                            </div>
                        }
                        value={
                            position === 0
                                ? "Next"
                                : typeof position === "undefined" || position === null
                                ? "N/A"
                                : position
                        }
                    />
                ) : null}
            </div>
            <QueueInfoItem
                title={"Active TA's"}
                loading={activeLoading}
                icon={
                    <div className="me-3 d-flex justify-content-center align-items-center">
                        <i className="fas fa-users fa-3x"></i>
                    </div>
                }
                value={activeTas?.map((v) => v.given_name).join(",")}
            />
            {enrollment?.role.name !== "student" ? (

                <div className="accordion mt-3" id="accordion-ta-log">
                    <div className="accordion-item">
                        <h2 className="accordion-header">
                            <button className="accordion-button collapsed" type="button" data-bs-toggle="collapse"
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
        </div>
    );
};
