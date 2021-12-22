import Rails from "rails-ujs";
import "@hotwired/turbo-rails";
import * as ActiveStorage from "@rails/activestorage";
import "../channels";
import "../controllers";

import queryClient from "../src/utilities/queryClientFile";
import ReactStudentChannel from "../channels/react_student_channel";

import attachTurboEvents from "../src/utilities/turboExtraEvents";
import Chart from "chart.js/auto";

attachTurboEvents();
nestedDropdownListeners();

window.queryClient = queryClient;
window.Chart = Chart;

import "../../assets/stylesheets/application.scss";
import "../src/utilities/attachPopoverListeners";
import nestedDropdownListeners from "../src/utilities/nestedDropdownListeners";

ReactStudentChannel.received = async (data) => {
  console.log("invalidating", data.invalidate);

  await queryClient.invalidateQueries(data.invalidate);

  await queryClient.refetchQueries(data.invalidate);
};

Rails.start();
ActiveStorage.start();