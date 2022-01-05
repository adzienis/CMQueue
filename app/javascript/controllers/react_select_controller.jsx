import { Controller } from "stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  initialize() {
    const select = this.element.querySelector("select");

    new TomSelect(select, {
      plugins: ["remove_button"]
    });
  }
}
