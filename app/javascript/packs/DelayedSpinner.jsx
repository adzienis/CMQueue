import {Spinner} from "react-bootstrap";
import React, {useEffect, useRef, useState} from "react";

export default props => {

    const {loading} = props;

    const [spin, setSpin] = useState(false)

    const timer = useRef()

    useEffect(() => {
        if (!loading) {
            clearTimeout(timer.current)
            setSpin(false)
        } else
        {
            timer.current = setTimeout(() => setSpin(true), 300)

            return () => {
                clearTimeout(timer.current)
                setSpin(false)
            }
        }
    }, [loading])
    return spin ? <Spinner
        as="span"
        animation="border"
        role="status"
        aria-hidden="true"
    /> : props.children
}