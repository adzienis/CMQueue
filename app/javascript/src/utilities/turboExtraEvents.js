

window.addEventListener('load', function() { initializeTurboFrameEvent() })
document.addEventListener('turbo:load', function() { initializeTurboFrameEvent() } )
document.addEventListener('react-component:load', function() { initializeTurboFrameEvent() } )

function initializeTurboFrameEvent() {
    const turboFrameEvent = new Event('not-turbo:frame-loaded')

    const observer = new MutationObserver(function(mutationList, observer) {
        document.dispatchEvent(turboFrameEvent)
    })

    const targetNodes = document.querySelectorAll("turbo-frame")
    const observerOptions = {
        childList: true,
        attributes: false,
        subtree: true
    }

    targetNodes.forEach(targetNode => observer.observe(targetNode, observerOptions))
}
