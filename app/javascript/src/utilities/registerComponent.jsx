import React from "react";
import ReactDOM from "react-dom";
import Root from "../components/Root";

/**
 * Singleton React component manager to handle rendering of React components
 *
 * Keeps track of components to be rendered, and attaches to events to determine
 * whether to render a registered component.
 *
 * Every time there is a "turbo:load" (when turbo loads, or renders the page), or
 * we detect a turbo frame has been updated "not-turbo:frame-loaded" has been fired,
 * then we iterate through the registered React components, and determine whether to render
 * them.
 *
 * A component is rendered if the target anchor tag has no child nodes (if there are any,
 * then that must mean a ReactDOM.render occurred at that node.
 *
 * When a component is rendered, we fire another event "react-component:load".
 */
class RegisterComponentManager {
  constructor() {
    this.registered_components = {};
  }

  register_component(Component, selector) {
    if (selector in this.registered_components) return false;

    this.registered_components[selector] = {
      instance: null,
      Component,
    };
  }

  register_hooks() {
    document.addEventListener("DOMContentLoaded", (e) =>
      this.render_components(e)
    );
    document.addEventListener("turbo:load", (e) => this.render_components(e));
    document.addEventListener("not-turbo:frame-loaded", (e) =>
      this.render_components(e)
    );
  }

  render_components(event) {
    const rootNode = document.querySelector("#root");
    if (rootNode) {
      const data = JSON.parse(rootNode.getAttribute("data"));

      ReactDOM.render(
        <Root registeredComponents={this.registered_components} {...data} />,
        rootNode
      );
    }
  }
}

const registerManager = new RegisterComponentManager();

export default registerManager;
