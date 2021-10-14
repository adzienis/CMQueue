import { Controller } from "stimulus";

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

function arraysEqual(a, b) {
  if (a === b) return true;
  if (a == null || b == null) return false;
  if (a.length !== b.length) return false;

  for (var i = 0; i < a.length; ++i) {
    if (a[i] !== b[i]) return false;
  }
  return true;
}

function selectEqualToValue(oldValue, newSelect, isMulti = false) {
  if (isMulti) {
    return arraysEqual(getSelectValues(newSelect), oldValue);
  } else {
    return newSelect.value === oldValue;
  }
}

function inputEqualToValue(oldValue, newInput) {
  if (newInput instanceof HTMLSelectElement) {
    const isMulti = newInput.getAttribute("multiple") != null;
    return selectEqualToValue(oldValue, newInput, isMulti);
  } else {
    return oldValue === newInput.value;
  }
}

export default class extends Controller {
  static targets = ["submit"];

  originalValues = new Map();
  disabled = false;

  initialize() {}

  connect() {
    const inputElements = [
      ...this.element.querySelectorAll("input,textarea,select"),
    ].filter((v) => v.name !== "authenticity_token");

    this.submitTarget.disabled = true;

    inputElements.forEach((v) => {
      if (v.classList.contains("is-invalid")) {
        this.originalValues.set(v, null);
        this.submitTarget.disabled = false;
      } else {
        this.originalValues.set(
          v,
          v instanceof HTMLSelectElement ? getSelectValues(v) : v.value
        );
      }

      if (v instanceof HTMLSelectElement) {
        v.onchange = (e) => {
          if (inputEqualToValue(this.originalValues.get(e), e))
            this.disabled = true;
          else {
            this.submitTarget.disabled = false;
            return;
          }

          let anyChanged = false;

          inputElements.forEach((elem) => {
            if (!inputEqualToValue(this.originalValues.get(elem), elem)) {
              anyChanged = true;
            }
          });

          this.disabled = !anyChanged;
          this.submitTarget.disabled = this.disabled;
        };
      } else {
        v.oninput = (e) => {
          //console.log(e.target, e.target.value)
          if (e.target.value === this.originalValues.get(e.target))
            this.disabled = true;
          else {
            this.submitTarget.disabled = false;
            return;
          }

          let anyChanged = false;

          inputElements.forEach((elem) => {
            if (!inputEqualToValue(this.originalValues.get(elem), elem)) {
              anyChanged = true;
            }
          });

          this.disabled = !anyChanged;
          this.submitTarget.disabled = this.disabled;
        };
      }
    });

    const values = [...inputElements].map((v) => v.value);
  }

  disconnect() {}
}
