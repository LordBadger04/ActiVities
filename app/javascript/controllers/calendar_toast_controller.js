import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  show(event) {
    event.preventDefault();

    const toast = document.createElement("div");
    toast.className = "calendar-toast";
    toast.innerHTML = `
      <i class="fa-solid fa-circle-check"></i>
      Event added to your calendar
    `;

    document.body.appendChild(toast);

    requestAnimationFrame(() => {
      toast.classList.add("calendar-toast--show");
    });

    setTimeout(() => {
      toast.classList.remove("calendar-toast--show");

      setTimeout(() => {
        toast.remove();
      }, 300);
    }, 2500);
  }
}
