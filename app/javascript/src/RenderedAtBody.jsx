import ReactDOM from "react-dom";
import React from "react";

export default (props) => {
  return ReactDOM.createPortal(props.children, document.querySelector("body"));
};
