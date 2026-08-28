Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.


    <section class="interests__col">
      <h2 class="chip">Hobbies</h2>
      <% if hobbies.any? %>
        <ul class="interests__list">
          <% hobbies.each do |ua| %>
            <li><%= ua.activity&.name %></li>
          <% end %>
        </ul>
      <% else %>
        <p class="interests__empty">Nothing yet</p>
      <% end %>
    </section>



<%= form_with url: root_path,
              method: :get,
              class: "search-bar" do %>

  <i class="fa-solid fa-magnifying-glass search-bar__icon" aria-hidden="true"></i>

  <label class="visually-hidden" for="activity-search">
    Search an activity
  </label>

  <%= search_field_tag :query,
      params[:query],
      id: "activity-search",
      placeholder: "Search an activity",
      class: "search-bar__input" %>

  <% if params[:latitude].present? %>
    <%= hidden_field_tag :latitude, params[:latitude] %>
  <% end %>

  <% if params[:longitude].present? %>
    <%= hidden_field_tag :longitude, params[:longitude] %>
  <% end %>
<% end %>

<% if params[:query].present? %>
  <section class="home-section home-section--search">
    <div class="home-section__head">
      <h2 class="section-label">Search results</h2>

      <%= link_to "Clear", root_path(
            latitude: params[:latitude],
            longitude: params[:longitude]
          ),
          class: "home-section__link" %>
    </div>

    <div class="home__feed">
      <% if @search_results.any? %>
        <% @search_results.each do |event| %>
          <%= render "events/activity_card", event: event %>
        <% end %>
      <% else %>
        <p class="empty-state">
          No activity found for "<%= params[:query] %>".
        </p>
      <% end %>
    </div>
  </section>
<% end %>
