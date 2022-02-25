// Load all the controllers within this directory and all subdirectories.
// Controller files must be named *_controller.js.

import { Application } from "stimulus";

import form_controller from "./form_controller";
import react_select_controller from "./react_select_controller";
import question_form_controller from "./question_form_controller";
import search_filter_controller from "./search_filter_controller";

import Autosave from "stimulus-rails-autosave";
import turbo_refresher_controller from "./turbo_refresher_controller";
import toast_controller from "./toast_controller";
import modal_component_controller from "./modal_component_controller";
import authenticated_controller from "./authenticated_controller";
import notification_setting_controller from "./notification_setting_controller";
import question_timer_controller from "./question_timer_controller";

window.Stimulus = Application.start();
Stimulus.register("form", form_controller);
Stimulus.register("react_select", react_select_controller);
Stimulus.register("question-form", question_form_controller);
Stimulus.register("search_filter", search_filter_controller);
Stimulus.register("autosave", Autosave);
Stimulus.register("turbo-refresher", turbo_refresher_controller);
Stimulus.register("toast", toast_controller);
Stimulus.register("modal-component", modal_component_controller);
Stimulus.register("authenticated", authenticated_controller);
Stimulus.register("notification-setting", notification_setting_controller);
Stimulus.register("question-timer", question_timer_controller);
