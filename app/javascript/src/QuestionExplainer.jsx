import React, {useRef, useState} from 'react';
import useWrappedMutation from "./useWrappedMutation";
import DelayedSpinner from "./DelayedSpinner";

export default props => {

    const {question, userId, callback, open, setOpen} = props;
    const [description, setDescription] = useState('')

    let newState = null;

    const refq = useRef();


    const {mutateAsync: createMessage, isLoading } = useWrappedMutation(() => ({
        message: {
            question_state_id: refq.current,
            user_id: userId,
            description
        }
    }), `/messages`, {}, {
        onSuccess: data => {

            setOpen(false)
        }
    })

    return <>
        <div className="modal fade" id="exampleModal" tabIndex="-1" aria-labelledby="exampleModalLabel"
             aria-hidden="true">
            <div className="modal-dialog modal-dialog-centered">
                <div className="modal-content">
                    <div className="modal-header">
                        <h5 className="modal-title" id="exampleModalLabel"> Explanation </h5>
                        <button type="button" className="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div className="modal-body">
                        <form>
                            <div className='mb-3'>
                                <label className="form-label"> <b>Description</b> </label>
                                <textarea rows={3} className="form-control" onChange={e => setDescription(e.target.value)}/>
                            </div>
                        </form>
                    </div>
                    <div className="modal-footer">
                        <button className="btn btn-primary" onClick={async e => {
                            try {
                                newState = await callback();
                                refq.current = newState?.id;
                                createMessage()
                            } catch (err) {

                            }
                        }}>
                            <DelayedSpinner loading={isLoading}>
                                Submit
                            </DelayedSpinner>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </>

}