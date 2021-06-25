import {QueryClient} from "react-query";
import defaultQueryFn from "./defaultFetchFn";

const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            queryFn: defaultQueryFn
        },

    },
})
document.addEventListener('turbo:before-fetch-request', e => {
    queryClient.getQueryCache().getAll().forEach(v => {
        v.observers.forEach(q => v.removeObserver(q))
    })
})



export default queryClient