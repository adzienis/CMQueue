import ApplicationController from './application_controller'

/* This is the custom StimulusReflex controller for the Course Reflex.
 * Learn more at: https://docs.stimulusreflex.com
 */
export default class extends ApplicationController {
    /*
     * Regular Stimulus lifecycle methods
     * Learn more at: https://stimulusjs.org/reference/lifecycle-callbacks
     *
     * If you intend to use this controller as a regular stimulus controller as well,
     * make sure any Stimulus lifecycle methods overridden in ApplicationController call super.
     *
     * Important:
     * By default, StimulusReflex overrides the -connect- method so make sure you
     * call super if you intend to do anything else when this controller connects.
    */

    static values = {courseId: Number}
    static targets = ["card"]


    connect() {
        super.connect()
        // add your code here, if applicable
    }

    click(e) {
        e.preventDefault();
        this.stimulate("courseCard#click", this.cardTarget.id)
    }

    addStudentCourseClick() {
        $('.ui.modal')
            .modal('show')
        ;
    }

    /* Reflex specific lifecycle methods.
     *
     * For every method defined in your Reflex class, a matching set of lifecycle methods become available
     * in this javascript controller. These are optional, so feel free to delete these stubs if you don't
     * need them.
     *
     * Important:
     * Make sure to add data-controller="course" to your markup alongside
     * data-reflex="Course#dance" for the lifecycle methods to fire properly.
     *
     * Example:
     *
     *   <a href="#" data-reflex="click->Course#dance" data-controller="course">Dance!</a>
     *
     * Arguments:
     *
     *   element - the element that triggered the reflex
     *             may be different than the Stimulus controller's this.element
     *
     *   reflex - the name of the reflex e.g. "Course#dance"
     *
     *   error/noop - the error message (for reflexError), otherwise null
     *
     *   reflexId - a UUID4 or developer-provided unique identifier for each Reflex
     */

    // Assuming you create a "Course#dance" action in your Reflex class
    // you'll be able to use the following lifecycle methods:

    // beforeDance(element, reflex, noop, reflexId) {
    //  element.innerText = 'Putting dance shoes on...'
    // }

    // danceSuccess(element, reflex, noop, reflexId) {
    //   element.innerText = '\nDanced like no one was watching! Was someone watching?'
    // }

    // danceError(element, reflex, error, reflexId) {
    //   console.error('danceError', error);
    //   element.innerText = "\nCouldn\'t dance!"
    // }

    // afterDance(element, reflex, noop, reflexId) {
    //   element.innerText = '\nWhatever that was, it\'s over now.'
    // }

    // finalizeDance(element, reflex, noop, reflexId) {
    //   element.innerText = '\nNow, the cleanup can begin!'
    // }
}
