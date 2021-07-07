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

                    console.log(k)

                    if (query.length > 0 && attribute.length > 0) {
                        f[attribute] = {};
                        f[attribute]["query"] = query;
                        f[attribute]["value"] = v;
                        f[attribute]["type"] = colNames[attribute] || associations[attribute];
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
                return (
                    `q[${k + "_" + v["query"]}]` +
                    "=" +
                    (v["value"] || "")
                );
            })
            .join("&")
    )

    return (
        <div className="card shadow-sm mb-2" style={{minHeight: '150px'}}>
            <div className="card-body">
                <div className="card-title">
                    <h4>Filters</h4>
                </div>
                {Object.keys(filters).map((v) => (
                    <FilterRow key={v} attribute={v} filters={filters} setFilters={setFilters} options={options}/>
                ))}
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
                                .concat(Object.keys(associations))
                                //.concat(
                                //Object.keys(associations)
                                //   .map((v) => associations[v].map((x) => `${v}_${x}`))
                                //   .flat()
                                //)
                                //.filter((v) => !except.includes(v))
                                .map((v) => (
                                    <li key={v}>
                                        <a
                                            href=""
                                            className="dropdown-item"
                                            onClick={(e) => {
                                                e.preventDefault();
                                                let copy = {...filters};

                                                if (!(v in Object.keys(filters))) {
                                                    copy[v] = {};
                                                    copy[v]["query"] = "eq";
                                                    copy[v]["type"] = colNames[v] || associations[v];
                                                }

                                                setFilters(copy);
                                            }}
                                        >
                                            {v}
                                        </a>
                                    </li>
                                ))}
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