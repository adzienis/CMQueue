import consumer from './consumer'
import CableReady from 'cable_ready'

consumer.subscriptions.create('StudentChannel', {
    connected() {
    },

    disconnected() {

    },

    received(data) {
        if (data.cableReady) CableReady.perform(data.operations);
    }
})