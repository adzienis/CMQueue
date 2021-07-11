import React from "react";

export default props => {
    const {error} = props;
    if (typeof error === "undefined") return null;

    if (error.error instanceof Array) {
        return (
            Object.entries(serverErrors)?.map(([attr, errs]) => (
                <div className="invalid-feedback d-block fw-bold">
                    {errs && (errs instanceof Array) && errs.map(err => `${attr} ${err}`).join(' and ')}
                </div>
            )))
    }

    return (
        <div className="invalid-feedback d-block fw-bold">
            {error.error}
        </div>
    )


}