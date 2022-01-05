import { QueryClient } from "react-query";
import defaultQueryFn from "./defaultFetchFn";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      queryFn: defaultQueryFn,
      refetchInterval: 1000 * 60,
      refetchIntervalInBackground: true,
    },
  },
});

export default queryClient;
