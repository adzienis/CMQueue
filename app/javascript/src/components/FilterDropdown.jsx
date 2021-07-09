import React, {useState} from "react";

import FilterRow from "./FilterRow";

const options = [
    ["Contains", "cont"],
    ["Equals", "eq"],
    ["Less than", "lt"],
    ["Greater than", "gt"],
    ["Less than/equal", "lteq"],
    ["Greater than/equal", "gteq"],
];

const options_values = options.map(v => v[1])

/**
 * This component handles the generation of filters for searching a model.
 *
 * @param props
 * @returns {JSX.Element}
 */
export default (props) => {
    const {columns, queries, except, base} = props;

    const {root: colNames, associations} = columns;

    const possible_values = Object.keys(colNames).concat(Object.keys(associations))

    const [filters, setFilters] = useState(
        /**
         * Here we initialize parameters from the query string,
         * and do basic validation for options and attributes.
         */
        (() => {
            let s = queries || {};

            let f = {};

            if (Object.entries(s)?.length > 0) {
                for (const [k, v] of Object.entries(s)) {

                    // sorting parameter
                    if (k === "s") continue;

                    const query = options_values
                        .filter(v => k.includes(v))
                        .reduce((x, y) => x.length > y.length ? x : y, "")

                    const attribute = possible_values
                        .filter(v => k.includes(v))
                        .reduce((x, y) => x.length > y.length ? x : y, "")

                    const t = {}
                    t["query"] = query;
                    t["value"] = v;
                    t["type"] = colNames[attribute]?.type || associations[attribute]?.type;
                    t["label"] = colNames[attribute]?.label || associations[attribute]?.label;

                    if (query.length > 0 && attribute.length > 0) {
                        if (f[attribute] instanceof Array) {
                            f[attribute].push(t)
                        } else {
                            f[attribute] = []
                            f[attribute].push(t)
                        }

                    } else {
                        continue;
                    }

                }
            } else {
                return {};
            }

            return f;
        })()
    );

    const searchValue = (
        base +
        '?' +
        Object.entries(filters)
            .map(([k, v]) => {
                return v.map(x => {
                    return (
                        `q[${k + "_" + x["query"]}]` +
                        "=" +
                        (x["value"] || "")
                    );
                }).join('&')
            })
            .join("&")
    )

    return (
        <div className="card shadow-sm mb-2" style={{minHeight: '150px'}}>
            <div className="card-body">
                <div className="card-title">
                    <h4>Filters</h4>
                </div>
                {Object.keys(filters).map((v) => {
                    return filters[v].map((x, i) =>
                        (
                            <FilterRow
                                key={x}
                                idx={i}
                                attribute={v}
                                filters={filters}
                                setFilters={setFilters}
                                options={options}/>
                        )
                    )
                })}
            </div>
            <div className="card-footer d-flex align-items-center">

                <div className="d-flex">
                    <div className="me-1">
                        <a
                            role="button"
                            className="btn btn-primary"
                            href={searchValue}
                        >
                            Filter
                        </a>
                    </div>
                    <div className="dropdown me-1">
                        <button
                            className="btn btn-secondary dropdown-toggle"
                            type="button"
                            id="dropdownMenuButton"
                            data-bs-toggle="dropdown"
                            aria-haspopup="true"
                            aria-expanded="false"
                        >
                            Add Filter
                        </button>
                        <ul
                            className="dropdown-menu"
                            aria-labelledby="dropdownMenuButton"
                        >
                            {Object.keys(colNames)
                                .map((v) => (
                                    <li key={v}>
                                        <a
                                            href=""
                                            className="dropdown-item"
                                            onClick={(e) => {
                                                e.preventDefault();
                                                let copy = {...filters};


                                                const t = {}
                                                t["query"] = "eq";
                                                t["type"] = colNames[v]?.type || associations[v]?.type;
                                                t["label"] = colNames[v]?.label || associations[v]?.label;

                                                if (copy[v] instanceof Array) {
                                                    copy[v].push(t)
                                                } else {
                                                    copy[v] = []
                                                    copy[v].push(t)
                                                }

                                                setFilters(copy);
                                            }}
                                        >
                                            {colNames[v]?.label || associations[v]?.label}
                                        </a>
                                    </li>
                                ))}
                            <li>
                                <hr className="dropdown-divider"/>
                            </li>
                            <div className="dropdown dropend">
                                <a className="dropdown-item dropdown-toggle" href="#" id="dropdown-layouts"
                                   data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Layouts</a>
                                <div className="dropdown-menu" aria-labelledby="dropdown-layouts">
                                    {Object.keys(associations)
                                        .map((v) => (
                                            <li key={v}>
                                                <a
                                                    href=""
                                                    className="dropdown-item"
                                                    onClick={(e) => {
                                                        e.preventDefault();
                                                        let copy = {...filters};


                                                        const t = {}
                                                        t["query"] = "eq";
                                                        t["type"] = colNames[v]?.type || associations[v]?.type;
                                                        t["label"] = colNames[v]?.label || associations[v]?.label;

                                                        if (copy[v] instanceof Array) {
                                                            copy[v].push(t)
                                                        } else {
                                                            copy[v] = []
                                                            copy[v].push(t)
                                                        }

                                                        setFilters(copy);
                                                    }}
                                                >
                                                    {colNames[v]?.label || associations[v]?.label}
                                                </a>
                                            </li>
                                        ))}
                                </div>
                            </div>
                        </ul>
                    </div>
                </div>
                <div>
                    <a href={base}>
                        <button className="btn btn-danger">Reset</button>
                    </a>
                </div>
            </div>
        </div>
    );
};