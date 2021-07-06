import React, {useEffect, useMemo, useRef, useState} from "react";

import DatePicker from "react-datepicker";
import { convertToDate } from "../utilities/dateConverter";


/**
 * Tries to handle the inputs generically.
 * Unfortunately, lot of timezone stuff because we need to shift to and from the local time zone.
 * @param props
 * @returns {JSX.Element}
 */
export default (props) => {
    const {className, style, colType, value, onInput, filters, setFilters, name} = props;

    const type = useMemo(() => {
        if (colType === "datetime") return "datetime-local";
        if (colType === "integer") return "number";
        if (colType === "text") return "text";
    }, []);

    const ref = useRef()

    const [date, setDate] = useState(new Date)


    useEffect(() => {
        if (colType === 'datetime' && value) {
            let copy = {...filters};
            const d = new Date(value);
            d.setHours(d.getHours() + d.getTimezoneOffset()/60)
            copy[name]["value"] = convertToDate(d);
            setFilters(copy);
            const adjusted_time = new Date(value);
            adjusted_time.setHours(adjusted_time.getHours() + adjusted_time.getTimezoneOffset() /60)
            setDate(adjusted_time)
        } else if(colType === 'datetime') {

            let copy = {...filters};
            copy[name]["value"] = convertToDate(date);
            setFilters(copy);
            const adjusted_time = new Date(date);
            adjusted_time.setHours(adjusted_time.getHours() + adjusted_time.getTimezoneOffset() /60)
            setDate(adjusted_time)
        }
    }, [])

    switch (type) {
        case "datetime-local":
            return <DatePicker
                ref={ref}
                className={className}
                selected={date}
                onChange={e => {
                    let copy = {...filters};
                    copy[name]["value"] = convertToDate(e);
                    setFilters(copy);
                    setDate(e)
                }
                }
            />
            break;

        default:

            return (
                <input
                    value={value}
                    onInput={onInput}
                    style={style}
                    className={className}
                    type={type}
                />
            );
            break;
    }
};
