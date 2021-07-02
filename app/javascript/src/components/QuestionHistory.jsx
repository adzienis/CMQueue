import React from "react";
import {useQuery} from "react-query";

export default (props) => {
  const { question } = props;

  const {data: question_states} = useQuery(['questions', question?.id, 'question_states'])

  console.log('id', question?.id)

  return (
    <>
      <button type="button" className="btn btn-secondary" data-bs-toggle="modal" data-bs-target="#historyModal">
        <i className="fas fa-history me-1"></i>
        <span>
        Past Question States
        </span>
      </button>

      <div className="modal fade" id="historyModal" tabIndex="-1" aria-labelledby="historyModal"
           aria-hidden="true">
        <div className="modal-dialog modal-dialog-centered modal-lg">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="historyModalLabel"> Question History </h5>
              <button type="button" className="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div className="modal-body">
              <turbo-frame id="container" src={`/courses/${question?.course_id}/question_states?q[question_id_eq]=${question?.id}&q[s]=created_at+desc`}></turbo-frame>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};
