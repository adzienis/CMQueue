import React, { useEffect, useMemo, useState } from "react";
import { useQuery, useQueryClient } from "react-query";
import {
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Scatter,
  ScatterChart,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import "react-datepicker/dist/react-datepicker.css";

export default (props) => {
  const { selectedQueueId, courseId, height = 470, limited = false } = props;

  const queryClient = useQueryClient();

  const [date, setDate] = useState(new Date());

  const {
    data: question_states,
    isFetching,
    isLoading,
  } = useQuery(
    ["activity", "?", `date=${date.toISOString()}`, `course_id=${courseId}`],
    {
      placeholderData: [],
      select: (d) => {
        if (d) {
          if (limited) {
            return d.filter(
              (x) => new Date() - new Date(x.created_at) < 60 * 60 * 1000 * 2
            );
          } else {
            return d;
          }
        }
      },
    }
  );

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

  const ticks = useMemo(() => {
    if (question_states.length > 0) {
      const mapped = question_states
        .filter(
          (x) =>
            new Date() - new Date(x.created_at) < 60 * 60 * 1000 * 2 || !limited
        )
        .map((v) => new Date(v.created_at).getTime());
      const minTime = mapped.reduce((prev, cur) => Math.min(prev, cur));
      const maxTime = mapped.reduce((prev, cur) => Math.max(prev, cur));

      const startTickDate = new Date(minTime);
      startTickDate.setHours(startTickDate.getHours());
      startTickDate.setMinutes(
        Math.floor((startTickDate.getMinutes() - 1) / 15) * 15
      );
      startTickDate.setSeconds(0);
      const endTickDate = new Date(maxTime);
      endTickDate.setHours(endTickDate.getHours());
      endTickDate.setMinutes(
        Math.ceil((endTickDate.getMinutes() + 1) / 15) * 15
      );
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
      margin={{ top: 5, right: 20, bottom: 5, left: 30 }}
      throttleDelay={500}
    >
      <Legend
        verticalAlign="top"
        height={36}
        iconSize={0}
        payload={[
          { value: "Resolved", id: "ID01", color: "var(--resolved)" },
          { value: "Frozen", id: "ID01", color: "var(--frozen)" },
        ]}
      />
      <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
      <XAxis
        scale="time"
        type="number"
        domain={["auto", "auto"]}
        dataKey="resolvedAt"
        tickFormatter={(timestamp) =>
          `${new Date(timestamp).toLocaleString("en-US", {
            hour: "numeric",
            minute: "numeric",
            hour12: true,
          })}`
        }
        ticks={ticks}
      />
      <YAxis
        type="category"
        dataKey="firstInit"
        allowDuplicatedCategory={false}
        style={{ fill: "black" }}
      />
      <Tooltip
        labelFormatter={() => undefined}
        formatter={(value, name, props) => {
          if (name === "firstInit") {
            return [undefined, undefined];
          }

          const val = [
            new Date(value).toLocaleTimeString(),
            props.payload.state,
          ];

          return val;
        }}
      />
      {taData.map((v) => (
        <Scatter
          key={v}
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
                    };
                    break;
                  case "frozen":
                    return {
                      stroke: `var(--frozen)`,
                      strokeWidth: "2px",
                    };
                    break;
                  case "unresolved":
                    return {
                      stroke: `var(--unresolved)`,
                      strokeWidth: "2px",
                    };
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
      <a
        href="#"
        data-bs-toggle="popover"
        title="Information"
        data-bs-content="Logs what action each TA has taken on a question within around 2 hours."
        onClick={(e) => e.preventDefault()}
      >
        <i className="fas fa-info-circle fa-lg" />
      </a>
      {isLoading || isFetching ? (
        <div
          style={{ height }}
          className="d-flex justify-content-center align-items-center w-100 bg-white"
        >
          <div className="spinner-border" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
        </div>
      ) : question_states?.length > 0 ? (
        <div className="">
          <ResponsiveContainer height={height} width="100%">
            {renderLineChart}
          </ResponsiveContainer>
        </div>
      ) : (
        <div
          className="d-flex justify-content-center align-items-center w-100"
          style={{ height }}
        >
          <h2>No data yet</h2>
        </div>
      )}
    </div>
  );
};
