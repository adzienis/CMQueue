import React, {useMemo, useState} from "react";
import {QueryClientProvider, useQuery, useQueryClient} from "react-query";
import {CartesianGrid, Legend, ResponsiveContainer, Scatter, ScatterChart, Tooltip, XAxis, YAxis,} from "recharts";
import ReactDOM from "react-dom";

import "react-datepicker/dist/react-datepicker.css";

const Component = (props) => {
    const {selectedQueueId, courseId} = props;

    const queryClient = useQueryClient();

    const [date, setDate] = useState(new Date());

    const {
        data: question_states,
        isFetching,
        isLoading,
    } = useQuery(
        [
            "courses",
            parseInt(courseId, 10),
            "question_states",
            "ta_feed",
            "?",
            `date=${date.toISOString()}`,
        ],
        {
            placeholderData: [],
        }
    );

    const startDate = useMemo(() => {
        if (date) {
            const d = new Date(date);
            d.setHours(0, 0, 0, 0);

            return d;
        }

        return null;
    }, [date]);

    const endDate = useMemo(() => {
        if (date) {
            const d = new Date(date);
            d.setHours(23, 59, 59, 59);

            return d;
        }
        return null;
    }, [date]);

    const taData = useMemo(() => {
        const uniqueTAs = new Set(question_states.map((v) => v.user_id));
        const taGroupedQuestions = [...uniqueTAs]
            .map((v) => ({
                data: question_states
                    .filter((x) => v === x.user_id)
                    .map((x) => ({
                        ...x,
                        firstInit: `${x.user.given_name} ${x.user.family_name.substring(
                            0,
                            1
                        )}`,
                        resolvedAt: new Date(x.created_at).getTime(),
                        count: 1,
                        taId: v,
                    })),
            }))
            .flat();

        return taGroupedQuestions;
    }, [question_states]);

    const getRandomColor = function () {
        const r = Math.random() * ((1 << 8) - 1);
        const g = Math.random() * ((1 << 8) - 1);
        const b = Math.random() * ((1 << 8) - 1);

        const rClamped = Math.min(120, r);
        const gClamped = Math.min(120, g);
        const bClamped = Math.min(120, b);

        const color =
            "#" +
            rClamped.toString(16).split(".")[0].padStart(2, "0") +
            gClamped.toString(16).split(".")[0].padStart(2, "0") +
            bClamped.toString(16).split(".")[0].padStart(2, "0");
        return color;
    };

    const ticks = useMemo(() => {
        if (question_states.length > 0) {
            const mapped = question_states.map((v) =>
                new Date(v.created_at).getTime()
            );
            const minTime = mapped.reduce((prev, cur) => Math.min(prev, cur));
            const maxTime = mapped.reduce((prev, cur) => Math.max(prev, cur));

            const startTickDate = new Date(minTime);
            startTickDate.setHours(startTickDate.getHours());
            startTickDate.setMinutes(0);
            startTickDate.setSeconds(0);
            const endTickDate = new Date(maxTime);
            endTickDate.setHours(endTickDate.getHours() + 1);
            endTickDate.setMinutes(0);
            endTickDate.setSeconds(0);

            const numTicks =
                (endTickDate.getTime() - startTickDate.getTime()) / 1000 / 60 / 15;
            const ticksMapped = new Array(Math.ceil(numTicks) + 1)
                .fill(null)
                .map((_, ind) => startTickDate.getTime() + 1000 * 60 * 15 * ind);

            return ticksMapped;
        }
        return [];
    }, [question_states]);

    const renderLineChart = (
        <ScatterChart
            margin={{top: 5, right: 20, bottom: 5, left: 30}}
            throttleDelay={500}
        >
            <Legend
                verticalAlign="top"
                height={36}
                iconSize={0}
                payload={[
                    {value: 'Resolved', id: 'ID01', color: "var(--resolved)"},
                    {value: 'Unresolved', type: 'line', id: 'ID01', color: "var(--unresolved)"},
                    {value: 'Frozen', type: 'line', id: 'ID01', color: "var(--frozen)"}
                ]}
            />
            <CartesianGrid stroke="#ccc" strokeDasharray="5 5"/>
            <XAxis
                scale="time"
                type="number"
                domain={["auto", "auto"]}
                dataKey="resolvedAt"
                tickFormatter={(timestamp) =>
                    `${new Date(timestamp).toLocaleString('en-US', {hour: 'numeric', minute: 'numeric', hour12: true})}`
                }
                ticks={ticks}
            />
            <YAxis
                type="category"
                dataKey="firstInit"
                allowDuplicatedCategory={false}
            />
            <Tooltip
                labelFormatter={() => undefined}
                formatter={(value, name, props) => {
                    if (name === "firstInit") {
                        return [undefined, undefined];
                    }
                    const val = [new Date(value).toLocaleTimeString(), props.payload.state];

                    return val;
                }}
            />
            {taData.map((v) => (
                <Scatter
                    dataKey="firstInit"
                    data={v.data}
                    shape={(pe) => (
                        <line
                            x1={pe.cx}
                            y1={pe.cy - 25}
                            x2={pe.cx}
                            y2={pe.cy}
                            style={(() => {
                                switch (pe.state) {
                                    case "resolved":
                                        return {
                                            stroke: `var(--resolved)`,
                                            strokeWidth: "2px",
                                        }
                                        break;
                                    case "frozen":
                                        return {
                                            stroke: `var(--frozen)`,
                                            strokeWidth: "2px",
                                        }
                                        break;
                                    case "unresolved":
                                        return {
                                            stroke: `var(--unresolved)`,
                                            strokeWidth: "2px",
                                        }
                                        break;
                                }
                            })()}
                        />
                    )}
                />
            ))}
        </ScatterChart>
    );
    return (
        <div className="bg-white p-3 shadow-sm">
            <h4 className="mb-4">
                Questions Answered
                <br/>
                <small className="text-muted">
                    Records when a TA has finished resolving questions
                </small>
            </h4>
            <div className="mb-2">
                <div>
                    <form>
                        <div>
                            <label className="form-label me-2 fw-bold">Date</label>
                            <input
                                type="date"
                                className="form-control w-auto"
                                onChange={(e) => setDate(new Date(e.target.value))}
                                value={date.toISOString().slice(0, 10)}
                            />
                        </div>
                    </form>
                </div>
            </div>

            {isLoading || isFetching ? (
                <div
                    style={{height: "470px"}}
                    className="d-flex justify-content-center align-items-center w-100 bg-white"
                >
                    <div className="spinner-border" role="status">
                        <span className="visually-hidden">Loading...</span>
                    </div>
                </div>
            ) : question_states?.length > 0 ? (
                <div className="">
                    <ResponsiveContainer height={470} width="100%">
                        {renderLineChart}
                    </ResponsiveContainer>
                </div>
            ) : (
                <div className="alert bg-white" style={{height: "470px"}}>
                    <span>No data yet!</span>
                </div>
            )}
        </div>
    );
};

document.addEventListener("turbo:load", (e) => {
    const node = document.querySelectorAll("#ta-chart");
    if (node.length > 0) {
        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute("data"));

            ReactDOM.render(
                <QueryClientProvider client={window.queryClient} contextSharing>
                    <Component {...data} />
                </QueryClientProvider>,
                v
            );
        });
    }
});
