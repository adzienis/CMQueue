import React, {useEffect, useRef, useState} from "react";

export default props => {

    const {loading} = props;

    const [spin, setSpin] = useState(false)

    const timer = useRef()

    useEffect(() => {
        if (!loading) {
            clearTimeout(timer.current)
            setSpin(false)
        } else {
            timer.current = setTimeout(() => setSpin(true), 300)

            return () => {
                clearTimeout(timer.current)
                setSpin(false)
            }
        }
    }, [loading])
    return spin ?
        <div className="spinner-border" role="status">
            <span className="visually-hidden">Loading...</span>
        </div> : props.children
}