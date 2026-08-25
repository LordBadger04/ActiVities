import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-form-input"
export default class extends Controller {
  static targets = ["form"]

  add(event) {
    event.preventDefault();
    this.formTarget.insertAdjacentHTML("afterend", this.formTarget.innerHTML)
  }
}
