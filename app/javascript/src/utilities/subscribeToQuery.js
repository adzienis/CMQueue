import { QueryObserver } from "react-query";
import queryClient from "./queryClientFile";

export default (queryKey, callback) => {
  const observer = new QueryObserver(queryClient, {
    queryKey: queryKey,
  });

  return observer.subscribe(callback);
};
