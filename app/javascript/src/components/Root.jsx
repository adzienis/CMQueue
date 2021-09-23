import React from "react";
import { QueryClientProvider } from "react-query";
import UserContext from "../context/UserContext";
import useLocalStorage from "../hooks/useLocalStorage";
import ReactDOM from "react-dom";

export default (props) => {
  const { registeredComponents, courseId } = props;

  const [selectedTags, setSelectedTags] = useLocalStorage(
    ["courses", parseInt(courseId, 10), "selectedTags"],
    []
  );

  return (
    <QueryClientProvider client={window.queryClient} contextSharing>
      <UserContext.Provider
        value={{
          selectedTags,
          setSelectedTags,
        }}
      >
        {Object.entries(registeredComponents)
          .map(([selector, componentWrapper]) => {
            const { Component, instance } = componentWrapper;

            const node = document.querySelectorAll(selector);

            if (node.length > 0) {
              const nodes = Array.from(node).map((v) => {
                const data = JSON.parse(v.getAttribute("data"));

                return ReactDOM.createPortal(
                  <Component key={selector} {...data} />,
                  v
                );
              });
              return nodes;
            }
            return [];
          })
          .flat()}
      </UserContext.Provider>
    </QueryClientProvider>
  );
};
