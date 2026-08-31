import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl";

export default class extends Controller {
  static values = {
    apiKey: String,
    latitude: Number,
    longitude: Number,
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12",
      center: [this.longitudeValue, this.latitudeValue],
      zoom: 15,
      interactive: false,
    });

    new mapboxgl.Marker({
      color: "#0f6e4e",
    })
      .setLngLat([this.longitudeValue, this.latitudeValue])
      .addTo(this.map);
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }
}
