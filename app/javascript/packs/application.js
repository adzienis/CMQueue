// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import './search_modal'
import './studentQueueView'
import './QuestionWaitingModal'
import './addCourseByCode'
import './QueueInfoPanel'
import './taQueueView'
import './QueueOpener'
import './QuestionAnswererPage'
import './filterDropdown'
import './taActionPane'
import queryClient from './queryClientFile'
import ReactStudentChannel from '../channels/react_student_channel'
//import './hello_react'

import { Turbo } from "@hotwired/turbo-rails"
window.Turbo = Turbo

ReactStudentChannel.received = async data => {
    console.log('invalidating', data.invalidate)

    //Turbo.visit(window.location.toString(), { action: 'replace' })
    await queryClient.invalidateQueries(data.invalidate)

    await queryClient.refetchQueries(data.invalidate)
}

Rails.start()
ActiveStorage.start()


import "controllers"

document.addEventListener('turbo:load', () => {
    //BSN.initCallback();

}, false);

document.addEventListener('turbo:before-cache', () => {
    const nodes = document.querySelectorAll('.collapse')

    for (const node of nodes) {
        node.classList.remove("show")
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