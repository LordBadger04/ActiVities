import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modals"
export default class extends Controller {
  connect() {
    console.log(this.element);
  }

  close(event) {
    event.preventDefault()
    this.element.classList.add("display-none")
  }
}
