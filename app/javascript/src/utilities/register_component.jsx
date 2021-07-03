import { QueryClientProvider } from "react-query";
import React from "react"
import ReactDOM from "react-dom";

export default (Component, selector) => {
    document.addEventListener("turbo:load", (e) => {
        const node = document.querySelectorAll(selector);
        if (node.length > 0) {
          node.forEach((v) => {
            const data = JSON.parse(v.getAttribute("data"));
      
            ReactDOM.render(
              <QueryClientProvider client={window.queryClient} contextSharing>
                <Component {...data} />
              </QueryClientProvider>,
              v
            );
          });
        }
      });
      
} 