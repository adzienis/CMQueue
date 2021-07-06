const logout = async () => {
  Turbo.visit("/sign_out");
};

export default async function ({ queryKey }) {
  let url = ``;
  let parameters = false;
  let firstParameter = true;

  queryKey.forEach((v) => {
    if (parameters) {
      if (firstParameter) {
        url += v;
        firstParameter = false;
      } else {
        url += `&${v}`;
      }

      return;
    }
    if (v === "?") {
      parameters = true;
      url += v;
    } else {
      url += `/${v}`;
    }
  });

  const resp = await fetch(`/api${url}`, {
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
    },
  });

  if (resp.status === 401) {
    logout();

    throw new Error(resp.status);
  }

  if (!resp.ok) {
    throw resp.statusText;
  }

  return await resp.json();
}
