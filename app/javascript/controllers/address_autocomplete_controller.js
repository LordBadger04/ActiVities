import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "input",
    "results",
    "latitude",
    "longitude",
  ];

  static values = {
    apiKey: String,
  };

  connect() {
    this.sessionToken = crypto.randomUUID();
    this.abortController = null;
  }

  async search() {
    const query = this.inputTarget.value.trim();

    if (query.length < 3) {
      this.resultsTarget.innerHTML = "";
      return;
    }

    if (this.abortController) {
      this.abortController.abort();
    }

    this.abortController = new AbortController();

    const params = new URLSearchParams({
      q: query,
      access_token: this.apiKeyValue,
      session_token: this.sessionToken,
      country: "FR,BE",
      language: "fr",
      limit: "5",
    });

    try {
      const response = await fetch(
        `https://api.mapbox.com/search/searchbox/v1/suggest?${params.toString()}`,
        { signal: this.abortController.signal },
      );

      if (!response.ok) return;

      const data = await response.json();

      this.renderSuggestions(data.suggestions || []);
    } catch (error) {
      if (error.name !== "AbortError") {
        console.error("Address autocomplete error:", error);
      }
    }
  }

  renderSuggestions(suggestions) {
    this.resultsTarget.innerHTML = "";

    suggestions.forEach((suggestion) => {
      const button = document.createElement("button");

      button.type = "button";
      button.classList.add("address-autocomplete__item");

      button.innerHTML = `
        <strong>${suggestion.name}</strong>
        <span>${suggestion.full_address || suggestion.place_formatted || ""}</span>
      `;

      button.addEventListener("click", () => {
        this.selectSuggestion(suggestion);
      });

      this.resultsTarget.appendChild(button);
    });
  }

  async selectSuggestion(suggestion) {
    const params = new URLSearchParams({
      access_token: this.apiKeyValue,
      session_token: this.sessionToken,
    });

    const response = await fetch(
      `https://api.mapbox.com/search/searchbox/v1/retrieve/${suggestion.mapbox_id}?${params.toString()}`,
    );

    if (!response.ok) return;

    const data = await response.json();
    const feature = data.features?.[0];

    if (!feature) return;

    const coordinates = feature.geometry?.coordinates;

    if (coordinates) {
      this.longitudeTarget.value = coordinates[0];
      this.latitudeTarget.value = coordinates[1];
    }

    const address =
      feature.properties?.full_address ||
      feature.properties?.name ||
      suggestion.full_address ||
      suggestion.name;

    this.inputTarget.value = address;
    this.resultsTarget.innerHTML = "";

    this.sessionToken = crypto.randomUUID();
  }
}
