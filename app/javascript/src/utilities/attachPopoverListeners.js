import Popover from "bootstrap/js/dist/popover";

window.addEventListener("DOMContentLoaded", instantiatePopovers);
window.addEventListener("turbo:load", instantiatePopovers);

export default function instantiatePopovers(event) {
  var popoverTriggerList = [].slice.call(
    document.querySelectorAll('[data-bs-toggle="popover"]')
  );

  var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new Popover(popoverTriggerEl);
  });
}
