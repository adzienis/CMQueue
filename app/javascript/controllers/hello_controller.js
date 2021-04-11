// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"
import ApplicationController from './application_controller'

export default class extends ApplicationController {
  static targets = []

  connect() {
    console.log('herer')
    //this.outputTarget.textContent = 'Hello, Stimulus!'
  }

  click() {
    console.log('clicked')
  }
}
