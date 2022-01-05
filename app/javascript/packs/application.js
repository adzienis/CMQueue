import Rails from "rails-ujs";
import "@hotwired/turbo-rails";
import * as ActiveStorage from "@rails/activestorage";
import "../channels";
import "../controllers";

import attachTurboEvents from "../src/utilities/turboExtraEvents";
import Chart from "chart.js/auto";
import 'chartjs-adapter-date-fns';

attachTurboEvents();
nestedDropdownListeners();

window.Chart = Chart;

import "../../assets/stylesheets/application.scss";
import "../src/utilities/attachPopoverListeners";
import nestedDropdownListeners from "../src/utilities/nestedDropdownListeners";

Rails.start();
ActiveStorage.start();