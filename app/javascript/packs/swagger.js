import SwaggerUI from "swagger-ui-react";
import "swagger-ui-react/swagger-ui.css";

import ReactDOM from "react-dom";
import React from "react";

// Render component with data
document.addEventListener("turbo:load", (e) => {
  const node = document.querySelectorAll("#swagger-ui-container");
  if (node.length > 0) {
    node.forEach((v) => {
      const data = JSON.parse(v.getAttribute("data"));

      ReactDOM.render(
        <SwaggerUI url="http://localhost:3000/api/swagger_doc" title="asdad" />,
        v
      );
    });
  }
});
