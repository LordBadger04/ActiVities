import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

export default class extends Controller {
  static targets = ["date", "startTime", "endTime"];

  connect() {
    this.datePicker = flatpickr(this.dateTarget, {
      dateFormat: "Y-m-d",
      minDate: "today",
      position: "below left",
    });

    this.startPicker = flatpickr(this.startTimeTarget, {
      enableTime: true,
      noCalendar: true,
      dateFormat: "H:i",
      time_24hr: true,
      position: "below left",
      onChange: (selectedDates, dateStr) => {
        this.endPicker.set("minTime", dateStr);

        if (this.endTimeTarget.value && this.endTimeTarget.value < dateStr) {
          this.endPicker.clear();
        }
      },
    });

    this.endPicker = flatpickr(this.endTimeTarget, {
      enableTime: true,
      noCalendar: true,
      dateFormat: "H:i",
      time_24hr: true,
      position: "below left",
    });
  }

  disconnect() {
    this.datePicker?.destroy();
    this.startPicker?.destroy();
    this.endPicker?.destroy();
  }
}
