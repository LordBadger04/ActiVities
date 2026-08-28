import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="switch-btn"
export default class extends Controller {
  static targets = ["movingShape", "leftShape", "rightShape"]

  connect() {
    console.log(this.rightShapeTarget)
  }
  switch(event) {
  event.preventDefault();
    if (event.target===this.rightShapeTarget) {
      this.movingShapeTarget.style.right = "2%";
      this.leftShapeTarget.classList.remove("switch-selected");
      this.rightShapeTarget.classList.add("switch-selected");
    } else if (event.target===this.leftShapeTarget) {
      this.movingShapeTarget.style.right = "52%";
      this.leftShapeTarget.classList.add("switch-selected");
      this.rightShapeTarget.classList.remove("switch-selected");
  }
  }
}
