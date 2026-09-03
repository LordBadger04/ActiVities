import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="calendarbtn"
export default class extends Controller {
  static targets = [ "btn" ]
  connect() {
    console.log("ok")
    console.log(this.btnTarget)
  }
}
