// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "rails-ujs";
import "@hotwired/turbo-rails";
import "bootstrap";
import "popper.js";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "../src/components/search_modal";
import "../src/components/studentQueueView";
import "../src/components/QuestionWaitingModal";
import "../src/components/addCourseByCode";
import "../src/components/QueueInfoPanel";
import "../src/components/taQueueView";
import "../src/components/QueueOpener";
import "../src/components/QuestionAnswererPage";
import "../src/components/filterDropdown";
import "../src/components/taActionPane";
import queryClient from "../src/components/queryClientFile";
import ReactStudentChannel from "../channels/react_student_channel";
import "../src/components/Prefetcher";
import "../src/components/CourseStatus";
import "../src/components/TALog";
import '../src/components/NotificationFeed'
import "../src/components/UserSettings"

import { Turbo } from "@hotwired/turbo-rails";
import "controllers";

window.Turbo = Turbo;
window.queryClient = queryClient;

ReactStudentChannel.received = async (data) => {
  console.log("invalidating", data.invalidate);

  //Turbo.visit(window.location.toString(), { action: 'replace' })
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

/*
queryClient.prefetchQuery(['courses', 1, 'open'])

queryClient.prefetchQuery(['courses', 1, 'questions', '?', `state=["unresolved"]`])

queryClient.prefetchInfiniteQuery(['courses', 1, 'paginatedPastQuestions'],
    ({pageParam = 0}) => {
        return fetch(`/courses/${1}/questions?cursor=${pageParam}&` +
            `state=["kicked", "resolved"]&course_id=${1}`, {
            headers: {
                'Accept': 'application/json'
            }
        }).then(resp => resp.json()).then(json => {

            return {
                cursor: json.cursor?.id,
                data: json.data
            }
        })
    }, {
        getNextPageParam: (lastPage, pages) => {
            return lastPage.cursor
        }
    })
*/
