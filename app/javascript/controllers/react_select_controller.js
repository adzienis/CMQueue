import { Controller} from 'stimulus'
import React from 'react'
import Select from 'react-select'
import ReactDOM from 'react-dom'


function getSelectValues(select) {
    var result = [];
    var options = select && select.options;
    var opt;

    for (var i = 0, iLen = options.length; i < iLen; i++) {
        opt = options[i];

        if (opt.selected) {
            result.push(opt.value || opt.text);
        }
    }
    return result;
}

export default class extends Controller {

    initialize() {
        this.init()
    }
    init() {
        const select = this.element.querySelector("select");
        // Hide the existing select
        select.style.display = "none";

        const options = [...select.options];

        const defaultValue = [...select.selectedOptions]

        const isMulti = select.getAttribute("multiple") != null;


        const onChange = value => {
            if (!Array.isArray(value)) {
                // Just set the value if this is a single select
                select.value = value.value;
            } else {
                // Update out native select option by option
                const selected = value.map(opt => opt.value);
                for (const opt of select.options) {
                    if (selected.includes(opt.value)) {
                        opt.selected = true
                    } else {
                        opt.selected = false
                    }
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