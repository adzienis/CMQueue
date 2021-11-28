import { Controller } from "stimulus";

export default class extends Controller {
  intervalTimer = null;

  initialize() {
    window.addEventListener("focus", this.checkAuth);
    this.intervalTimer = setInterval(() => {
      this.checkAuth(null);
    }, 1000 * 60 * 10);
  }

  async checkAuth(event) {
    if (window.location.pathname === "/") return;

    const resp = await fetch("/users/authenticated", {
      credentials: "include",
      headers: {
        Accept: "application/json",
      },
    });

    if (resp.status === 401 && window.location.pathname !== "/") {
      Turbo.visit("/");
    }
  }

  disconnect() {
    if (this.intervalTimer) clearInterval(this.intervalTimer);
  }
}
