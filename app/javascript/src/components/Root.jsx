import React from "react";
import { QueryClientProvider } from "react-query";
import RenderedAt from "./RenderedAt";
import UserContext from "../context/UserContext";
import useLocalStorage from "../hooks/useLocalStorage";

export default (props) => {
  const { registeredComponents, courseId } = props;

  const [selectedTags, setSelectedTags] = useLocalStorage([
    "courses",
    parseInt(courseId, 10),
    "selectedTags",
  ]);

  return (
    <QueryClientProvider client={window.queryClient} contextSharing>
      {Object.entries(registeredComponents)
        .map(([selector, componentWrapper]) => {
          const { Component, instance } = componentWrapper;

          const node = document.querySelectorAll(selector);

          if (node.length > 0) {
            const nodes = Array.from(node).map((v) => {
              const data = JSON.parse(v.getAttribute("data"));

              return (
                <UserContext.Provider
                  value={{
                    selectedTags,
                    setSelectedTags,
                  }}
                >
                  <RenderedAt selector={selector}>
                    <Component key={selector} {...data} />
                  </RenderedAt>
                </UserContext.Provider>
              );
            });
            return nodes;
          }
          return [];
        })
        .flat()}
    </QueryClientProvider>
  );
};
