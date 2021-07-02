export default async function mutationFn(url, options = {}, body = {}) {
  const token = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");

  const resp = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": token,
      Accept: "application/json",
    },
    body: JSON.stringify(body),
    ...options,
  });

  if (!resp.ok) throw resp.statusText;

  return null;
}
