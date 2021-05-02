import {QueryClient} from "react-query";
import defaultQueryFn from "./defaultFetchFn";
import {createLocalStoragePersistor} from "react-query/createLocalStoragePersistor-experimental";
import {persistQueryClient} from "react-query/persistQueryClient-experimental";

const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            cacheTime: 1000*60,
            queryFn: defaultQueryFn
        },

    },
})


/*
const localStoragePersistor = createLocalStoragePersistor()

persistQueryClient({
    queryClient,
    persistor: localStoragePersistor,
})
*/
document.addEventListener('turbo:before-fetch-request', e => {
    console.log('clearing')
    queryClient.getQueryCache().getAll().forEach(v => {
        v.observers.forEach(q => v.removeObserver(q))
    })
})

export default queryClient