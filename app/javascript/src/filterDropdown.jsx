import React, {useState} from 'react'
import ReactDOM from 'react-dom'
import {QueryClientProvider} from "react-query";

import FormInput from "./FormInput";

const Component = props => {

    const {columns, queries, except, reset } = props;

    const {root:colNames, associations} = columns;

    const options = [["Contains", "cont"], ["Equals", "eq"]]

    const [filters, setFilters] = useState((() => {
        let s = queries || {}

        let f = {}

        if (Object.entries(s)?.length > 0) {
            for (const [k, v] of Object.entries(s)) {
                const split = k.split('_')
                const last = split.slice(split.length - 1).join('')
                const first = split.slice(0, split.length - 1).join('_')

                if (last === 's') continue;

                f[first] = {}
                f[first]["query"] = last
                f[first]["value"] = v
            }
        } else {
            return {}
        }

        return f;
    })());


    return (
        <div className="card shadow-sm mb-2">
            <div className="card-body">
                <div className="card-title">
                    <h4>
                        Filters
                    </h4>
                </div>
                <form>
                    {
                        Object.keys(filters).map(v => (
                            <div className="filter-row">
                                <div className="d-flex justify-content-start align-items-center"
                                     style={{marginRight: '1rem'}}>
                                    <b>
                                        {v}
                                    </b>
                                </div>
                                <div className="w-auto">
                                    <select className="form-select w-100">
                                        <option> none</option>
                                        {options.map(([k, val]) => (
                                            <option
                                                selected={filters[v]["query"] === val}
                                                value={val}
                                                onClick={e => {
                                                    filters[v] = filters[v] ? filters[v] : {}
                                                    filters[v]["query"] = e.target.value
                                                    setFilters(filters)
                                                }}
                                            > {k}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                                <div className="d-flex ">
                                    <FormInput
                                        colType={'text'}
                                        className="form-control w-auto me-2"
                                        onInput={e => {
                                            let copy = {...filters}
                                            copy[v]["value"] = e.target.value
                                            setFilters(copy)
                                        }} value={filters[v]["value"]}
                                        style={{ maxWidth: "90%"}}
                                    />
                                    <div style={{display: 'flex', justifyContent: 'center', alignItems: 'center'}}>
                                        <a href="" onClick={e => {
                                            e.preventDefault()
                                            let copy = {...filters}
                                            delete copy[v]

                                            setFilters(copy)
                                        }}>
                                            <i className="fas fa-times fa-lg"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        ))
                    }
                    <div className="d-flex align-items-center mb-4">
                        <div className="dropdown me-1">
                            <button className="btn btn-secondary dropdown-toggle" type="button"
                                    id="dropdownMenuButton" data-bs-toggle="dropdown" aria-haspopup="true"
                                    aria-expanded="false">
                                Add Filter
                            </button>
                            <ul className="dropdown-menu" aria-labelledby="dropdownMenuButton">
                                {colNames.concat(Object.keys(associations).map(v => associations[v].map(x => `${v}_${x}`)).flat()).filter(v => !except.includes(v)).map(v =>
                                    <li>
                                        <a href="" className="dropdown-item"
                                           onClick={e => {
                                               e.preventDefault()
                                               let copy = {...filters}

                                               if (!(v in Object.keys(filters))) {
                                                   copy[v] = {}
                                                   copy[v]["query"] = "eq"
                                               }

                                               setFilters(copy)
                                           }}
                                        >
                                            {v}
                                        </a>
                                    </li>
                                )}
                            </ul>
                        </div>
                    </div>
                    <div className="d-flex">
                        <div className="me-1">
                            <button className="btn btn-primary" onClick={e => {
                                e.preventDefault()
                                const search = window.location.search ? "?" : "?"

                                Turbo.visit(window.location.pathname +
                                    search + "&" +
                                    Object.entries(filters).map(([k, v]) => {
                                        return `q[${k + "_" + v["query"]}]` + "=" + (v["value"] || "")
                                    }).join('&'))
                            }}>
                                Filter
                            </button>
                        </div>
                        <div>

                            <a href={reset}>
                                <button className="btn btn-danger">
                                    Reset
                                </button>
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    )

}

// Render component with data
document.addEventListener('turbo:load', (e) => {
    const node = document.querySelectorAll('#dropdown-filter')
    if (node.length > 0) {

        node.forEach((v) => {
            const data = JSON.parse(v.getAttribute('data'))

            ReactDOM.render(<QueryClientProvider client={window.queryClient}
                                                 contextSharing><Component {...data}/></QueryClientProvider>, v)
        })
    }
})