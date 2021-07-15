import React, {useEffect, useRef, useState} from "react";
import useWrappedMutation from "../hooks/useWrappedMutation";
import DelayedSpinner from "./DelayedSpinner";
import useAutoFocusModal from "../hooks/useAutoFocusModal";

export default (props) => {
  const { question, userId, callback, open, setOpen } = props;
  const [description, setDescription] = useState("");

  let newState = null;

  const refq = useRef();

  useAutoFocusModal('#explanationModal', '#explanation')

  return (
    <>
      <div
        className="modal fade"
        id="explanationModal"
        tabIndex="-1"
      >
        <div className="modal-dialog modal-dialog-centered modal-lg">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title">
                {" "}
                Explanation{" "}
              </h5>
              <button
                type="button"
                className="btn-close"
                data-bs-dismiss="modal"
              />
            </div>
            <div className="modal-body">
              <form>
                <div className="mb-3">
                  <label className="form-label">
                    {" "}
                    <b>Description</b>{" "}
                  </label>
                  <textarea
                      id="explanation"
                    rows={3}
                    className="form-control"
                    onChange={(e) => setDescription(e.target.value)}
                  />
                </div>
              </form>
            </div>
            <div className="modal-footer">
              <button
                className="btn btn-primary"
                onClick={async (e) => {
                  try {
                    newState = await callback(description);
                    refq.current = newState?.id;
                  } catch (err) {}
                }}
              >
                <DelayedSpinner>Submit</DelayedSpinner>
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};
