// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { Application } from "stimulus";

import form_controller from "./form_controller";
import modal_controller from "./modal_controller";
import react_select_controller from "./react_select_controller";

window.Stimulus = Application.start();
Stimulus.register("form", form_controller);
Stimulus.register("modal", modal_controller);
Stimulus.register("react_select", react_select_controller);
