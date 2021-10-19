import { Controller } from "stimulus";
import React from "react";
import Select from "react-select";
import ReactDOM from "react-dom";

export default class extends Controller {
  static values = { course_id: Number };

  async initialize() {
    const urlSearchParams = new URLSearchParams(window.location.search);
    const params = Object.fromEntries(urlSearchParams.entries());

    const resp = await fetch(
      `/analytics/dashboards/metabase/dashboards?course_id=${this.courseIdValue}`,
      {
        headers: {
          Accept: "application/json",
        },
      }
    );

    const dashboards = await resp.json();

    const select = this.element.querySelector("select");

    select.childNodes.forEach((v) => v.remove());

    dashboards.forEach((dashboard) => {
      const dashNode = document.createElement("option");
      dashNode.setAttribute("value", dashboard["id"]);
      dashNode.innerHTML = dashboard["name"];

      select.appendChild(dashNode);
    });
    this.init();
  }
  init() {
    const select = this.element.querySelector("select");
    select.style.display = "none";
    const options = [...select.options];

    const defaultValue = [...select.selectedOptions];

    const isMulti = select.getAttribute("multiple") != null;

    const onChange = (value) => {
      if (!Array.isArray(value)) {
        // Just set the value if this is a single select
        select.value = value.value;
      } else {
        // Update out native select option by option
        const selected = value.map((opt) => opt.value);
        for (const opt of select.options) {
          opt.selected = !!selected.includes(opt.value);
        }
      }

      select.dispatchEvent(new Event("change"));
    };

    // Add the react-select
    const reactSelect = document.createElement("div");
    select.parentNode.insertBefore(reactSelect, select);
    ReactDOM.render(
      <Select
        options={options}
        defaultValue={defaultValue}
        onChange={onChange}
        isMulti={isMulti}
      />,
      reactSelect
    );

    // Mark that we've been initialized
    this.data.set("initialized", true);
  }
}
