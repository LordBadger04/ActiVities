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
      zoom: 12,
      interactive: false,
    });

    this.map.on("load", () => {
      this.addApproximateArea();
    });
  }

  addApproximateArea() {
    this.map.addSource("event-location", {
      type: "geojson",
      data: {
        type: "Feature",
        geometry: {
          type: "Point",
          coordinates: [this.longitudeValue, this.latitudeValue],
        },
      },
    });

    this.map.addLayer({
      id: "event-location-area",
      type: "circle",
      source: "event-location",
      paint: {
        "circle-radius": 30,
        "circle-color": "#0f6e4e",
        "circle-opacity": 0.25,
        "circle-stroke-width": 2,
        "circle-stroke-color": "#0f6e4e",
      },
    });
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }
}
