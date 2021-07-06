import { useMutation } from "react-query";
import React, { useState } from "react";

export default function useWrappedMutation(
  extractor,
  url,
  options = {},
  mutationOptions = {}
) {
  const token = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");

  const [errors, setErrors] = useState({});

  const handle = useMutation(
    async (args) => {
      //setErrors({})

      const { url: urlBody, ...body } = extractor(args);

      const resp = await fetch(urlBody ? urlBody : url, {
        method: "POST",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": token,
        },
        body: JSON.stringify(body),
        ...options,
      });

      if (!resp.ok) {
        const json = await resp.json();
        throw JSON.stringify(json);
      }

      return await resp.json();
    },
    {
      onError: (err) => {
        const errors = JSON.parse(err);
        setErrors(errors);
      },
      retry: false,
      ...mutationOptions,
    }
  );

  return { ...handle, errors, setErrors };
}
