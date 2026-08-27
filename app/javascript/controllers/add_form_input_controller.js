import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-form-input"
export default class extends Controller {
  static targets = ["formTemplate", "formList"]
  static values = { pattern: String }

  add(event) {
    event.preventDefault();
    event.stopPropagation();
    this.formListTarget.insertAdjacentHTML("beforeend", this.generateFormHTML());
  }

  destroy(event) {
    event.preventDefault();
    event.stopPropagation();
    event.currentTarget.parentNode.remove();
  }

  toggle_red(event) {
    event.currentTarget.classList.toggle("red")
    event.currentTarget.classList.toggle("visible")
  }

  generateFormHTML() {
    const html = this.formTemplateTarget.innerHTML.toString();
    return html.replaceAll(this.patternValue, new Date().getTime());
  }
}
