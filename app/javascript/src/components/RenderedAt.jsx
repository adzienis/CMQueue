import ReactDOM from "react-dom";
import React from "react";

export default (props) => {
  const { selector } = props;

  return ReactDOM.createPortal(
    props.children,
    document.querySelector(selector)
  );
};
