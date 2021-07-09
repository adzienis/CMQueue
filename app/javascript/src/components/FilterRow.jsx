import React from 'react'
import FormInput from "./FormInput"


function getOptions(type) {
    switch (type) {
        case "datetime":
            return (
                [
                    ["Equals", "eq"],
                    ["Before", "lt"],
                    ["After", "gt"],
                    ["Before/on", "lteq"],
                    ["After/on", "gteq"],
                ]
            )
        case "text":
            return (
                [
                    ["Contains", "cont"],
                    ["Equals", "eq"]
                ]
            )
        default:
            return (
                [
                    ["Contains", "cont"],
                    ["Equals", "eq"],
                    ["Less than", "lt"],
                    ["Greater than", "gt"],
                    ["Less than/equal", "lteq"],
                    ["Greater than/equal", "gteq"],
                ]
            );
    }
}


export default props => {

    const {filters, setFilters, attribute, idx } = props;

    const {query, value, type, label } = filters[attribute][idx];

    const options = getOptions(type)

    return (
        <div className="d-flex align-items-center filter-row w-100 mb-3" style={{maxWidth: '650px'}} key={attribute}>

            <a
                className="border rounded-circle me-4"
                style={{
                    height: '35px', width: '35px',
                    display: "flex",
                    justifyContent: "center",
                    alignItems: "center",
                }}
                href=""
                onClick={(e) => {
                    e.preventDefault();
                    let copy = {...filters};
                    delete copy[attribute][idx];

                    setFilters(copy);
                }}
            >
                <i className="fas fa-times"/>
            </a>
            <div
                className="d-flex justify-content-start align-items-center me-3 mb-0"
                style={{minWidth: '100px'}}
            >
                <b>{label}</b>
            </div>
            <div className="w-auto me-3 mb-0">
                <select
                    defaultValue={filters[attribute][idx]["query"]}
                    className="form-select rounded-pill"
                    style={{minWidth: '100px'}}
                    onInput={(e) => {
                        const copy = {...filters}
                        copy[attribute][idx] = copy[attribute][idx] ? copy[attribute][idx] : {};
                        copy[attribute][idx]["query"] = e.target.value;
                        setFilters(copy);
                    }}
                >
                    {options.map(([k, val]) => (
                        <option
                            key={`${k}${val}`}
                            defaultValue={filters[attribute][idx]["query"] === val}
                            value={val}
                        >
                            {k}
                        </option>
                    ))}
                </select>
            </div>


            <div className="d-flex mb-0" style={{minWidth: '100px'}}>
                <FormInput
                    idx={idx}
                    name={attribute}
                    query={filters[attribute][idx]["query"]}
                    colType={filters[attribute][idx]["type"]}
                    className="form-control me-2"
                    filters={filters}
                    setFilters={setFilters}
                    onInput={(e) => {
                        let copy = {...filters};
                        copy[attribute][idx]["value"] = e.target.value;
                        setFilters(copy);
                    }}
                    value={filters[attribute][idx]["value"]}
                />
            </div>
        </div>
    )
}