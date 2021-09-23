import Modal from "bootstrap/js/dist/modal";
import React, { useEffect, useRef } from "react";

export default (props) => {
  const { action } = props;

  const modalRef = useRef();
  const modalInstRef = useRef();

  useEffect(() => {
    if (modalRef.current) {
      modalInstRef.current = new Modal(modalRef.current);
    }
  }, [modalRef.current]);

  return (
    <>
      <div
        ref={modalRef}
        className="modal fade"
        tabIndex="-1"
        aria-hidden="true"
      >
        <div className="modal-dialog modal-dialog-centered">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="exampleModalLabel">
                Delete Confirmation
              </h5>
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              />
            </div>
            <div className="modal-body">
              Are you sure you want to delete this?
            </div>
            <div className="modal-footer">
              <button
                onClick={(e) => {
                  e.preventDefault();
                  action();
                  modalInstRef.current.hide();
                }}
              >
                Confirm
              </button>
            </div>
          </div>
        </div>
      </div>
      <div onClick={(e) => modalInstRef.current.toggle()}>{props.children}</div>
    </>
  );
};
