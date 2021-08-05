import React, { useEffect } from "react";

export default function (modalSelector, inputSelector) {
  useEffect(() => {
    const modal = document.querySelector(modalSelector);
    const input = document.querySelector(inputSelector);

    modal?.addEventListener("shown.bs.modal", function () {
      input?.focus();
    });
  });
}
