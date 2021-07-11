import {QueryClientProvider} from "react-query";
import React from "react"
import ReactDOM from "react-dom";




class RegisterComponentManager {
    constructor() {
        this.registered_components = {};
    }

    register_component(Component, selector) {
        if(selector in this.registered_components) return false;

        this.registered_components[selector] = {
            instance: null,
            Component
        };
    }

    register_hooks() {
        document.addEventListener("turbo:load", e => this.render_components(e));
        document.addEventListener("not-turbo:frame-loaded", e => {
            this.render_components(e)
        });
    }

    render_components(event) {
        Object.entries(this.registered_components).forEach(([selector, componentWrapper]) => {
            const { Component, instance } = componentWrapper;


            const node = document.querySelectorAll(selector);

            if (node.length > 0) {
                node.forEach((v) => {
                    const data = JSON.parse(v.getAttribute("data"));

                    const reference = ReactDOM.render(
                        <QueryClientProvider client={window.queryClient} contextSharing>
                            <Component {...data} />
                        </QueryClientProvider>,
                        v, () => {
                        }
                    );
                });
            }

        })
    }
}

``



const registerManager = new RegisterComponentManager();

export default registerManager;


/*
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

            // emit event for when this component is physically in the DOM tree
            // TODO: possibly guarantee by searching with query selectors?
            const turboFrameEvent = new Event('react-component:load')
            console.log('loaded')
            document.dispatchEvent(turboFrameEvent)
        }
    });

    document.addEventListener("turbo:load", e => {

        const turboFrameEvent = new Event('react-component:load')

        const observer = new MutationObserver(function (mutationList, observer) {
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

            // emit event for when this component is physically in the DOM tree
            // possibly guarantee by searching with query selectors?
            const turboFrameEvent = new Event('react-component:load')
            document.dispatchEvent(turboFrameEvent)
        }
    });
} */