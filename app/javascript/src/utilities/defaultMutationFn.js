export default async (url, options) => {
  const token = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");

  const resp = await fetch(url, {
    method: "POST",
    ...options,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-CSRF-Token": token,
      ...options?.headers,
    },
    body: JSON.stringify(options?.body),
  });

  if (!resp.ok) {
    const json = await resp.json();
    return json;
  }

  return await resp.json();
};
