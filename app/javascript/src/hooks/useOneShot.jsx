import React, { useCallback, useRef } from "react";

export default function (f) {
  const counter = useRef(0);

  return useCallback(() => {
    if (counter.current === 0) {
      counter.current += 1;
      f();
    }
  });
}
