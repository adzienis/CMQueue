import React from "react";

export default (props) => {
  const { title, value, icon, loading, footer } = props;

  return (
    <div
      className="card bg-white"
    >
      <div className="card-body d-flex flex-row">
        {loading ? (
          <div className="d-flex justify-content-center align-items-center w-100">
            <div className="spinner-border" role="status">
              <span className="visually-hidden">Loading...</span>
            </div>
          </div>
        ) : (
          <>
            {icon}
            <div>
              <div className="card-title mb-1 text-nowrap">
                <b>{title}</b>
              </div>
              <div className="card-text">
                <p className="h2 text-secondary">{value}</p>
              </div>
            </div>
          </>
        )}
      </div>
      <div className="card-footer p-0">
        {footer}
      </div>
    </div>
  );
};
