import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll"
export default class extends Controller {
  static targets = [ "messages", "message" ]
  connect() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight - this.messagesTarget.clientHeight;
  }
  messageTargetConnected() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight - this.messagesTarget.clientHeight;
  }
}
