// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "rails-ujs";
import "@hotwired/turbo-rails";
import "bootstrap";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import { Turbo } from "@hotwired/turbo-rails";
import "controllers";
import "../src/utilities/register_component";


import SearchModal from "../src/components/search_modal";
import StudentQueueView from "../src/components/studentQueueView";
import AddCourseByCode from "../src/components/addCourseByCode";
import FilterDropdown from "../src/components/filterDropdown";
import queryClient from "../src/components/queryClientFile";
import ReactStudentChannel from "../channels/react_student_channel";
import CourseStatus from "../src/components/CourseStatus";
import NotificationFeed from "../src/components/NotificationFeed";
import Prefetcher from "../src/components/Prefetcher";
import register_component from "../src/utilities/register_component";
import QuestionAnswererPage from "../src/components/QuestionAnswererPage";
import QueueInfoPanel from "../src/components/QueueInfoPanel";
import TAActionPane from "../src/components/taActionPane";
import TALog from "../src/components/TALog";
import TAQueueView from "../src/components/taQueueView";
import UserSettings from "../src/components/UserSettings";

register_component(AddCourseByCode, "#add-course-by-code");
register_component(CourseStatus, "#course-status");
register_component(FilterDropdown, "#dropdown-filter");
register_component(NotificationFeed, "#notification-feed");
register_component(Prefetcher, "#prefetcher");
register_component(QuestionAnswererPage, "#question-answerer");
register_component(QueueInfoPanel, "#queue-info-panel");
register_component(SearchModal, "#hello-react");
register_component(StudentQueueView, "#student-queue-view");
register_component(TAActionPane, "#ta-action-pane");
register_component(TALog, "#ta-chart");
register_component(TAQueueView, "#ta-queue-view");
register_component(UserSettings, "#user-settings");

window.Turbo = Turbo;
window.queryClient = queryClient;

ReactStudentChannel.received = async (data) => {
  console.log("invalidating", data.invalidate);

  await queryClient.invalidateQueries(data.invalidate);

  await queryClient.refetchQueries(data.invalidate);
};

Rails.start();
ActiveStorage.start();

document.addEventListener("turbo:before-cache", () => {
  const nodes = document.querySelectorAll(".collapse");

  for (const node of nodes) {
    node.classList.remove("show");
  }
});
