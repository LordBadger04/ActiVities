import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="switch-btn"
export default class extends Controller {
  static targets = ["movingShape", "leftShape", "rightShape", "right", "left"]

  switch(event) {
    event.preventDefault();
    if (event.target===this.rightShapeTarget) {
      this.moveRight()
    } else if (event.target===this.leftShapeTarget) {
      this.moveLeft()
    }
  }

  moveRight() {
    this.movingShapeTarget.style.right = "0%";
    this.leftShapeTarget.classList.remove("switch-selected");
    this.rightShapeTarget.classList.add("switch-selected");
    this.rightTargets.forEach(target => {
      target.classList.remove("event-hidden")
    });
    this.leftTargets.forEach(target => {
      target.classList.add("event-hidden")
    });
  }

  moveLeft() {
    this.movingShapeTarget.style.right = "50%";
    this.leftShapeTarget.classList.add("switch-selected");
    this.rightShapeTarget.classList.remove("switch-selected");
    this.rightTargets.forEach(target => {
          target.classList.add("event-hidden")
        });
        this.leftTargets.forEach(target => {
          target.classList.remove("event-hidden")
        });
  }
}
