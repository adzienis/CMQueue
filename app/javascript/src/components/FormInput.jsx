import React, { useMemo } from "react";

export default (props) => {
  const { className, style, colType, value, onInput } = props;

  const type = useMemo(() => {
    if (colType === "datetime") return "datetime-local";
    if (colType === "integer") return "number";
    if (colType === "text") return "text";
  }, []);

  return (
    <input
      value={value}
      onInput={onInput}
      style={style}
      className={className}
      type={type}
    />
  );
};
