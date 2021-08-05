import React, { useEffect } from "react";

export default (props) => {
  const { children, id, src } = props;

  useEffect(() => {
    const turboFrameEvent = new Event("react-component:load");
    document.dispatchEvent(turboFrameEvent);
  }, []);

  return (
    <turbo-frame id={id} src={src}>
      {children}
    </turbo-frame>
  );
};
