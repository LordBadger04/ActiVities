import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="switch-btn"
export default class extends Controller {
  static targets = ["movingShape", "leftShape", "rightShape", "eventsComing", "eventsCanceled"]

  connect() {
    console.log(this.eventsCanceledTargets.value)
  }

  switch(event) {
    console.log(this.eventsCanceledTargets)
    event.preventDefault();
    if (event.target===this.rightShapeTarget) {
      this.movingShapeTarget.style.right = "0%";
      this.leftShapeTarget.classList.remove("switch-selected");
      this.rightShapeTarget.classList.add("switch-selected");
      this.eventsComingTargets.forEach(target => {
        target.classList.add("event-hidden")
      });
      this.eventsCanceledTargets.forEach(target => {
        target.classList.remove("event-hidden")
      });
    } else if (event.target===this.leftShapeTarget) {
      this.movingShapeTarget.style.right = "50%";
      this.leftShapeTarget.classList.add("switch-selected");
      this.rightShapeTarget.classList.remove("switch-selected");
      this.eventsComingTargets.forEach(target => {
        target.classList.remove("event-hidden")
      });
      this.eventsCanceledTargets.forEach(target => {
        target.classList.add("event-hidden")
      });
  }
  }
}
