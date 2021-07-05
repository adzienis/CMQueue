import React, { useEffect, useMemo, useState } from 'react';
import { useQuery, useQueryClient } from 'react-query';
import {
    CartesianGrid,
    Line,
    LineChart,
    ResponsiveContainer,
    Tooltip,
    XAxis,
    YAxis,
} from 'recharts';

function WaitTime(props) {
    const { selectedQueueId, match } = props;

    const queryClient = useQueryClient();

    const [date, setDate] = useState(new Date());


    const binnedData = useMemo(() => {
        if (taStatesData?.length > 0) {
            const mapped = taStatesData
                .map((v) => [
                    new Date(v.start).getTime(),
                    new Date(v.end).getTime(),
                ])
                .flat();

            const minTime = mapped.reduce((prev, cur) => Math.min(prev, cur));
            const maxTime = mapped.reduce((prev, cur) => Math.max(prev, cur));

            const startDataDate = new Date(minTime);
            startDataDate.setHours(startDataDate.getHours());
            startDataDate.setMinutes(0);
            startDataDate.setSeconds(0);
            const endDataDate = new Date(maxTime);

            const numTicks =
                (endDataDate.getTime() - startDataDate.getTime()) /
                1000 /
                60 /
                15;
            const ticksMapped = new Array(Math.ceil(numTicks) + 2)
                .fill(null)
                .map((_, ind) => {
                    const timeIdx = new Date(
                        startDataDate.getTime() + 1000 * 60 * 15 * ind,
                    );

                    const waitTime = taStatesData
                        .filter(
                            (v) =>
                                (v.start < timeIdx && v.end > timeIdx) ||
                                (v.start > timeIdx - 1000 * 60 * 15 &&
                                    v.start < timeIdx &&
                                    v.end < timeIdx),
                        )
                        .map((v) =>
                            v.end > timeIdx
                                ? timeIdx - v.start
                                : v.end - v.start,
                        );

                    const clampedWait =
                        waitTime.length > 0
                            ? waitTime.reduce((acc, cur) => acc + cur) /
                            waitTime.length
                            : 0;

                    return {
                        time: timeIdx.getTime(),
                        value: Math.ceil(clampedWait / 1000 / 60),
                    };
                });

            return ticksMapped;
        }

        return [];
    }, [taStatesData]);

    const getRandomColor = function () {
        const r = Math.random() * ((1 << 8) - 1);
        const g = Math.random() * ((1 << 8) - 1);
        const b = Math.random() * ((1 << 8) - 1);

        const rClamped = Math.min(120, r);
        const gClamped = Math.min(120, g);
        const bClamped = Math.min(120, b);

        const color =
            '#' +
            rClamped.toString(16).split('.')[0].padStart(2, '0') +
            gClamped.toString(16).split('.')[0].padStart(2, '0') +
            bClamped.toString(16).split('.')[0].padStart(2, '0');
        return color;
    };

    const renderLineChart = (
        <LineChart
            margin={{ top: 5, right: 40, bottom: 5, left: -15 }}
            throttleDelay={500}
        >
            <CartesianGrid stroke="#ccc" strokeDasharray="5 5" />
            <XAxis
                domain={['auto', 'auto']}
                type="number"
                scale="time"
                dataKey="time"
                tickFormatter={(timestamp) =>
                    `${new Date(timestamp).getHours()}:${new Date(timestamp)
                        .getMinutes()
                        .toString()
                        .padStart(2, '0')}`
                }
            />
            <YAxis
                type="number"
                dataKey="value"
                domain={['auto', 'dataMax']}
                allowDuplicatedCategory={false}
                allowDecimals={false}
            />
            <Tooltip
                anim
                labelFormatter={(label) => new Date(label).toLocaleTimeString()}
                formatter={(value, name) => {
                    if (name === 'time') {
                        return [new Date(value).toLocaleTimeString(), name];
                    }
                    const val = [`${value} min`, 'Wait Time'];

                    return val;
                }}
            />
            <Line dataKey="value" data={binnedData} fill={getRandomColor()} />
        </LineChart>
    );

    return (
        <Segment>
            <Header style={{ marginBottom: '5px' }}>
                Average Wait Time
                <Header.Subheader>
                    Average time for a question to be answered since being asked
                </Header.Subheader>
            </Header>
            <Menu borderless secondary>
                <Menu.Item fitted>
                    <Form>
                        <Form.Field>
                            <label>Range</label>
                            <SemanticDatepicker
                                onChange={(_, d) => setDate(d.value)}
                                value={date}
                            />
                        </Form.Field>
                    </Form>
                </Menu.Item>
            </Menu>
            <Divider />

            {binnedData?.length > 0 ? (
                <ResponsiveContainer height={500} width="100%">
                    {renderLineChart}
                </ResponsiveContainer>
            ) : (
                <Message warning> No data yet!</Message>
            )}
        </Segment>
    );
}

export default withRouter(WaitTime);
