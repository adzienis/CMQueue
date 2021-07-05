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

    document.addEventListener("turbo:load", e => {

        const turboFrameEvent = new Event('react-component:load')

        const observer = new MutationObserver(function(mutationList, observer) {
            document.dispatchEvent(turboFrameEvent)
        })

        const targetNodes = document.querySelectorAll(selector)
        const observerOptions = {
            childList: true,
            attributes: false,
            subtree: true
        }

        targetNodes.forEach(targetNode => observer.observe(targetNode, observerOptions))
    })

    document.addEventListener("not-turbo:frame-loaded", (e) => {
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