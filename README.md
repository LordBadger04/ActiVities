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
