import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    activityId: Number,
  };

  focus() {
    window.dispatchEvent(
      new CustomEvent("activity:focus", {
        detail: {
          id: this.activityIdValue,
        },
      }),
    );
  }
}
