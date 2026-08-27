import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["latitude", "longitude"];

  connect() {
    if (!navigator.geolocation) return;

    const url = new URL(window.location.href);

    // Évite une boucle de rechargement si on a déjà les coordonnées
    if (url.searchParams.has("latitude") && url.searchParams.has("longitude")) {
      return;
    }

    navigator.geolocation.getCurrentPosition((position) => {
      const latitude = position.coords.latitude;
      const longitude = position.coords.longitude;

      this.latitudeTarget.value = latitude;
      this.longitudeTarget.value = longitude;

      url.searchParams.set("latitude", latitude);
      url.searchParams.set("longitude", longitude);

      window.location.href = url.toString();
    });
  }
}
