import React from 'react'
import FormInput from "./FormInput"


function getOptions(type) {
    switch (type) {
        case "datetime":
            return (
                [
                    ["Equals", "eq"],
                    ["Less than", "lt"],
                    ["Greater than", "gt"],
                    ["Less than/equal", "lteq"],
                    ["Greater than/equal", "gteq"],
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

    const {filters, setFilters, attribute} = props;

    const {query, value, type} = filters[attribute];

    const options = getOptions(type)

    return (
        <div className="filter-row w-100" style={{maxWidth: '700px'}} key={attribute}>
            <div
                className="d-flex justify-content-start align-items-center me-1 mb-1"
                style={{minWidth: '100px'}}
            >
                <b>{attribute}</b>
            </div>
            <div className="mb-0" style={{flex: 1}}/>
            <div className="d-flex">
                <div className="w-auto me-3">
                    <select
                        defaultValue={filters[attribute]["query"]}
                        className="form-select"
                        style={{minWidth: '100px'}}
                        onInput={(e) => {
                            const copy = {...filters}
                            copy[attribute] = copy[attribute] ? copy[attribute] : {};
                            copy[attribute]["query"] = e.target.value;
                            setFilters(copy);
                        }}
                    >
                        {options.map(([k, val]) => (
                            <option
                                key={`${k}${val}`}
                                defaultValue={filters[attribute]["query"] === val}
                                value={val}
                            >
                                {k}
                            </option>
                        ))}
                    </select>
                </div>
                <div className="d-flex" style={{minWidth: '100px'}}>
                    <FormInput
                        name={attribute}
                        query={filters[attribute]["query"]}
                        colType={filters[attribute]["type"]}
                        className="form-control w-auto me-2"
                        filters={filters}
                        setFilters={setFilters}
                        onInput={(e) => {
                            let copy = {...filters};
                            copy[attribute]["value"] = e.target.value;
                            setFilters(copy);
                        }}
                        value={filters[attribute]["value"]}
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
                                delete copy[attribute];

                                setFilters(copy);
                            }}
                        >
                            <i className="fas fa-times fa-lg"/>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    )
}