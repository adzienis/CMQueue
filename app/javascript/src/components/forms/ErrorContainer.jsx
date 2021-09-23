import { ErrorMessage } from "@hookform/error-message";
import React from "react";

export default (props) => {
  const { errors, name } = props;

  return (
    <ErrorMessage
      name={name}
      errors={errors}
      render={({ message }) => {
        return <div className="d-block invalid-feedback">{message}</div>;
      }}
    />
  );
};
