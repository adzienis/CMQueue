import React, {useRef, useState} from 'react';
import useWrappedMutation from "./useWrappedMutation";
import {Button, Form, Modal} from "react-bootstrap";

export default props => {

    const {question, userId, callback, open, setOpen} = props;
    const [description, setDescription] = useState('')

    let newState = null;

    const refq = useRef();


    const {mutateAsync: createMessage} = useWrappedMutation(() => ({
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

    return (
        <Modal show={open} centered onHide={e => setOpen(false)} size='lg'>
            <Modal.Body>
                <Form>
                    <Form.Group className='mb-3'>
                        <label> Description </label>
                        <Form.Control as='textarea' onChange={e => setDescription(e.target.value)}/>
                    </Form.Group>
                    <Button onClick={async e => {
                        try {
                            newState = await callback();
                            refq.current = newState?.id;
                            createMessage()
                        } catch (err) {

                        }
                    }}>
                        Submit
                    </Button>
                </Form>
            </Modal.Body>
        </Modal>
    )
}