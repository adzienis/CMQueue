import React, {useState} from "react";

import FormInput from "./FormInput";

export default (props) => {
    const {columns, queries, except, base} = props;

    const {root: colNames, associations} = columns;

    const options = [
        ["Contains", "cont"],
        ["Equals", "eq"],
    ];

    const [filters, setFilters] = useState(
        (() => {
            let s = queries || {};

            let f = {};

            if (Object.entries(s)?.length > 0) {
                for (const [k, v] of Object.entries(s)) {
                    const split = k.split("_");
                    const last = split.slice(split.length - 1).join("");
                    const first = split.slice(0, split.length - 1).join("_");

                    if (last === "s") continue;

                    f[first] = {};
                    f[first]["query"] = last;
                    f[first]["value"] = v;
                }
            } else {
                return {};
            }

            return f;
        })()
    );

    //const search = window.location.search ? "?" : "?";

    const searchValue =  (
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
        <div className="card shadow-sm mb-2" style={{ minHeight: '150px'}}>
            <div className="card-body">
                <div className="card-title">
                    <h4>Filters</h4>
                </div>
                <form>
                    {Object.keys(filters).map((v) => (
                        <div className="filter-row" key={v}>
                            <div
                                className="d-flex justify-content-start align-items-center me-1"
                                style={{minWidth: '100px'}}
                            >
                                <b>{v}</b>
                            </div>
                            <div className="w-auto">
                                <select className="form-select w-auto" style={{minWidth: '100px'}}>
                                    {options.map(([k, val]) => (
                                        <option
                                            key={`${k}${val}`}
                                            defaultValue={filters[v]["query"] === val}
                                            value={val}
                                            onClick={(e) => {
                                                filters[v] = filters[v] ? filters[v] : {};
                                                filters[v]["query"] = e.target.value;
                                                setFilters(filters);
                                            }}
                                        >
                                            {" "}
                                            {k}
                                        </option>
                                    ))}
                                </select>
                            </div>
                            <div className="d-flex" style={{minWidth: '100px'}}>
                                <FormInput
                                    colType={"text"}
                                    className="form-control w-auto me-2"
                                    onInput={(e) => {
                                        let copy = {...filters};
                                        copy[v]["value"] = e.target.value;
                                        setFilters(copy);
                                    }}
                                    value={filters[v]["value"]}
                                    style={{minWidth: '80px'}}
                                />
                                <div
                                    style={{
                                        display: "flex",
                                        justifyContent: "center",
                                        alignItems: "center",
                                    }}
                                >
                                    <a
                                        href=""
                                        onClick={(e) => {
                                            e.preventDefault();
                                            let copy = {...filters};
                                            delete copy[v];

                                            setFilters(copy);
                                        }}
                                    >
                                        <i className="fas fa-times fa-lg"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    ))}

                </form>
            </div>
            <div className="card-footer d-flex align-items-center">

                <div className="d-flex">
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
                            {colNames
                                .concat(
                                    Object.keys(associations)
                                        .map((v) => associations[v].map((x) => `${v}_${x}`))
                                        .flat()
                                )
                                .filter((v) => !except.includes(v))
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
                <div className="me-1">
                    <a
                        role="button"
                        className="btn btn-primary"
                        href={searchValue}
                    >
                        Filter
                    </a>
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