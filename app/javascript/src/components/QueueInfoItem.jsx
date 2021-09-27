import React from "react";

export default (props) => {
  const { title, value, icon, loading, footer, info } = props;

  const mobile = window.innerWidth < 792;

  return (
    <div className="card bg-white position-relative">
      {info ? (
        <a
          className="position-absolute"
          style={{ right: "10px", top: "10px" }}
          href="#"
          data-bs-toggle="popover"
          title="Information"
          data-bs-content={info}
          onClick={(e) => e.preventDefault()}
        >
          <i className="fas fa-info-circle fa-lg" />
        </a>
      ) : null}
      <div className="card-body d-flex flex-row" style={{ minHeight: "115px" }}>
        {loading ? (
          <div className="d-flex justify-content-center align-items-center w-100">
            <div className="spinner-border" role="status">
              <span className="visually-hidden">Loading...</span>
            </div>
          </div>
        ) : (
          <>
            {!mobile && icon}
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
      <div className="card-footer p-0">{footer}</div>
    </div>
  );
};
