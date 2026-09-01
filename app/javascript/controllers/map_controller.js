import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl";

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array,
    userLocation: Object,
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/rachthedev/cmtitfuu600ba01quaf7r6n4k",
      center: [2.35, 48.86],
      zoom: 9,
    });

    this.map.on("load", () => {
      this.addApproximateAreas();
      this.addUserArea();
      this.centerOnUser();
    });
  }

  disconnect() {
    if (this.map) {
      this.map.remove();
    }
  }

  addUserArea() {
    if (!this.hasUserLocationValue) return;

    this.map.addSource("user-location", {
      type: "geojson",
      data: {
        type: "Feature",
        geometry: {
          type: "Point",
          coordinates: [
            this.userLocationValue.longitude,
            this.userLocationValue.latitude,
          ],
        },
      },
    });

    this.map.addLayer({
      id: "user-area",
      type: "circle",
      source: "user-location",
      paint: {
        "circle-radius": 18,
        "circle-color": "#dfff2f",
        "circle-opacity": 0.45,
        "circle-stroke-width": 3,
        "circle-stroke-color": "#0f6e4e",
      },
    });

    this.map.on("click", "user-area", (event) => {
      new mapboxgl.Popup()
        .setLngLat(event.lngLat)
        .setHTML("<strong>Your approximate area</strong>")
        .addTo(this.map);
    });
  }

  addApproximateAreas() {
    const features = this.markersValue.map((marker) => ({
      type: "Feature",
      geometry: {
        type: "Point",
        coordinates: [marker.longitude, marker.latitude],
      },
      properties: {
        id: marker.id,
        title: marker.title,
        url: marker.url,
      },
    }));

    this.map.addSource("activities", {
      type: "geojson",
      data: {
        type: "FeatureCollection",
        features: features,
      },
    });

    this.map.addLayer({
      id: "activity-areas",
      type: "circle",
      source: "activities",
      paint: {
        "circle-radius": 30,
        "circle-color": "#0f6e4e",
        "circle-opacity": 0.25,
        "circle-stroke-width": 2,
        "circle-stroke-color": "#0f6e4e",
      },
    });

    this.map.on("click", "activity-areas", (event) => {
      const feature = event.features[0];

      new mapboxgl.Popup()
        .setLngLat(feature.geometry.coordinates)
        .setHTML(
          `
        <div class="map-popup">
          <strong>${feature.properties.title}</strong>
          <span>Approximate area</span>
          <a href="${feature.properties.url}" class="map-popup__link">
            View activity
          </a>
        </div>
      `,
        )
        .addTo(this.map);
    });

    this.map.on("mouseenter", "activity-areas", () => {
      this.map.getCanvas().style.cursor = "pointer";
    });

    this.map.on("mouseleave", "activity-areas", () => {
      this.map.getCanvas().style.cursor = "";
    });
  }

  centerOnUser() {
    if (!this.hasUserLocationValue) return;

    this.map.flyTo({
      center: [
        this.userLocationValue.longitude,
        this.userLocationValue.latitude,
      ],
      zoom: 8,
      essential: true,
    });
  }

  focusUser() {
    if (!this.hasUserLocationValue) return;

    this.map.flyTo({
      center: [
        this.userLocationValue.longitude,
        this.userLocationValue.latitude,
      ],
      zoom: 8,
      essential: true,
    });

    this.element.scrollIntoView({
      behavior: "smooth",
      block: "center",
    });
  }

  focusActivity(event) {
    const activityId = event.detail.id;

    const marker = this.markersValue.find((marker) => marker.id === activityId);

    if (!marker) return;

    this.map.flyTo({
      center: [marker.longitude, marker.latitude],
      zoom: 13,
      essential: true,
    });

    this.element.scrollIntoView({
      behavior: "smooth",
      block: "center",
    });
  }
}
