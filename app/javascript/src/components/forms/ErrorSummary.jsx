import React from "react";

export default (props) => {
  const { errors } = props;

  return (
    Object.values(errors).length > 0 && (
      <div className="alert alert-danger">
        {Object.values(errors).map((error) => (
          <div className="d-block invalid-feedback">{error.message}</div>
        ))}
      </div>
    )
  );
};
