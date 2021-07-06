import React, { useMemo } from "react";

import DatePicker from "react-datepicker";


export default (props) => {
  const { className, style, colType, value, onInput } = props;

  const type = useMemo(() => {
    if (colType === "datetime") return "datetime-local";
    if (colType === "integer") return "number";
    if (colType === "text") return "text";
  }, []);

  switch (type) {
    case "datetime-local":
      return <DatePicker
          className={className}
          selected={new Date}/>
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
