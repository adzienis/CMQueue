import Rails from "rails-ujs";
import "@hotwired/turbo";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import * as Turbo from "@hotwired/turbo"
import "controllers";
import "../src/utilities/registerComponent";

import bootstrap from 'bootstrap/dist/js/bootstrap'

document.addEventListener('react-component:load', event => {
  (function($bs) {
    const CLASS_NAME = 'has-child-dropdown-show';
    $bs.Dropdown.prototype.toggle = function(_orginal) {
      return function() {
        document.querySelectorAll('.' + CLASS_NAME).forEach(function(e) {
          e.classList.remove(CLASS_NAME);
        });
        let dd = this._element.closest('.dropdown').parentNode.closest('.dropdown');
        for (; dd && dd !== document; dd = dd.parentNode.closest('.dropdown')) {
          dd.classList.add(CLASS_NAME);
        }
        return _orginal.call(this);
      }
    }($bs.Dropdown.prototype.toggle);

    document.querySelectorAll('.dropdown').forEach(function(dd) {
      dd.addEventListener('hide.bs.dropdown', function(e) {
        if (this.classList.contains(CLASS_NAME)) {
          this.classList.remove(CLASS_NAME);
          e.preventDefault();
        }
        if(e.clickEvent && e.clickEvent.composedPath().some(el=>el.classList && el.classList.contains('dropdown-toggle'))){
          e.preventDefault();
        }
        e.stopPropagation(); // do not need pop in multi level mode
      });
    });

    // for hover
    function getDropdown(element) {
      return $bs.Dropdown.getInstance(element) || new $bs.Dropdown(element);
    }

    document.querySelectorAll('.dropdown-hover, .dropdown-hover-all .dropdown').forEach(function(dd) {
      dd.addEventListener('mouseenter', function(e) {
        let toggle = e.target.querySelector(':scope>[data-bs-toggle="dropdown"]');
        if (!toggle.classList.contains('show')) {
          getDropdown(toggle).toggle();
        }
      });
      dd.addEventListener('mouseleave', function(e) {
        let toggle = e.target.querySelector(':scope>[data-bs-toggle="dropdown"]');
        if (toggle.classList.contains('show')) {
          getDropdown(toggle).toggle();
        }
      });
    });
  })(bootstrap);
})

document.addEventListener("turbo:load", event => {
  (function($bs) {
    const CLASS_NAME = 'has-child-dropdown-show';
    $bs.Dropdown.prototype.toggle = function(_orginal) {
      return function() {
        document.querySelectorAll('.' + CLASS_NAME).forEach(function(e) {
          e.classList.remove(CLASS_NAME);
        });
        let dd = this._element.closest('.dropdown').parentNode.closest('.dropdown');
        for (; dd && dd !== document; dd = dd.parentNode.closest('.dropdown')) {
          dd.classList.add(CLASS_NAME);
        }
        return _orginal.call(this);
      }
    }($bs.Dropdown.prototype.toggle);

    document.querySelectorAll('.dropdown').forEach(function(dd) {
      dd.addEventListener('hide.bs.dropdown', function(e) {
        if (this.classList.contains(CLASS_NAME)) {
          this.classList.remove(CLASS_NAME);
          e.preventDefault();
        }
        if(e.clickEvent && e.clickEvent.composedPath().some(el=>el.classList && el.classList.contains('dropdown-toggle'))){
          e.preventDefault();
        }
        e.stopPropagation(); // do not need pop in multi level mode
      });
    });

    // for hover
    function getDropdown(element) {
      return $bs.Dropdown.getInstance(element) || new $bs.Dropdown(element);
    }

    document.querySelectorAll('.dropdown-hover, .dropdown-hover-all .dropdown').forEach(function(dd) {
      dd.addEventListener('mouseenter', function(e) {
        let toggle = e.target.querySelector(':scope>[data-bs-toggle="dropdown"]');
        if (!toggle.classList.contains('show')) {
          getDropdown(toggle).toggle();
        }
      });
      dd.addEventListener('mouseleave', function(e) {
        let toggle = e.target.querySelector(':scope>[data-bs-toggle="dropdown"]');
        if (toggle.classList.contains('show')) {
          getDropdown(toggle).toggle();
        }
      });
    });
  })(bootstrap);
})





import SearchModal from "../src/components/SearchModal";
import StudentQueueView from "../src/components/StudentQueueView";
import AddCourseByCode from "../src/components/AddCourseByCode";
import FilterDropdown from "../src/components/FilterDropdown";
import queryClient from "../src/utilities/queryClientFile";
import ReactStudentChannel from "../channels/react_student_channel";
import CourseStatus from "../src/components/CourseStatus";
import NotificationFeed from "../src/components/NotificationFeed";
import Prefetcher from "../src/components/Prefetcher";
import QuestionAnswererPage from "../src/components/QuestionAnswererPage";
import QueueInfoPanel from "../src/components/QueueInfoPanel";
import TAActionPane from "../src/components/TAActionPane";
import TALog from "../src/components/TALog";
import TAQueueView from "../src/components/TAQueueView";
import UserSettings from "../src/components/UserSettings";
import TATimePerQuestion from "../src/components/TATimePerQuestion";

import attachTurboEvents from "../src/utilities/turboExtraEvents";
import registerManager from "../src/utilities/registerComponent";
registerManager.register_component(AddCourseByCode, "#add-course-by-code");
registerManager.register_component(CourseStatus, "#course-status");
registerManager.register_component(FilterDropdown, "#dropdown-filter");
registerManager.register_component(NotificationFeed, "#notification-feed");
registerManager.register_component(Prefetcher, "#prefetcher");
registerManager.register_component(QuestionAnswererPage, "#question-answerer");
registerManager.register_component(QueueInfoPanel, "#queue-info-panel");
registerManager.register_component(SearchModal, "#hello-react");
registerManager.register_component(StudentQueueView, "#student-queue-view");
registerManager.register_component(TAActionPane, "#ta-action-pane");
registerManager.register_component(TALog, "#ta-chart");
registerManager.register_component(TAQueueView, "#ta-queue-view");
registerManager.register_component(UserSettings, "#user-settings");
//registerManager.register_component(TATimePerQuestion, "#time");

attachTurboEvents();

registerManager.render_components();
registerManager.register_hooks();


window.Turbo = Turbo;
window.queryClient = queryClient;

ReactStudentChannel.received = async (data) => {
  console.log("invalidating", data.invalidate);

  await queryClient.invalidateQueries(data.invalidate);

  await queryClient.refetchQueries(data.invalidate);
};

Rails.start();
ActiveStorage.start();

