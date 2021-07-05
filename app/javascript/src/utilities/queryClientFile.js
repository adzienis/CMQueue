import { QueryClient } from "react-query";
import defaultQueryFn from "../components/defaultFetchFn";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      queryFn: defaultQueryFn,
    },
  },
});
document.addEventListener("turbo:before-fetch-response", (e) => {
  queryClient
    .getQueryCache()
    .getAll()
    .forEach((v) => {
      //v.observers.forEach((q) => v.removeObserver(q));
    });
});

export default queryClient;
