Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.




<%= f.input :username,
                required: true%>
    <%= f.input :first_name,
                required: true,
                input_html: { autocomplete: "first-name" }%>
    <%= f.input :last_name,
                required: true,
                input_html: { autocomplete: "last-name" }%>
    <%= f.input :age,
                required: true,
                autofocus: true,
                input_html: { autocomplete: "age" }%>
    <%= f.input :gender,
                required: true,
                autofocus: true%>
    <%= f.input :language,
                label: "Languages spoken",
                required: true%>
    <%= f.input :location,
                label: "City",
                required: true
                %>
    <%= f.input :description,
                label: 'Describe yourself (15 letters min)',
                required: true %>
    <%= f.association :activities,
                      as: :check_boxes,
                      label: "Choose your activities" %>



has_many :user_activities, dependent: :destroy
  has_many :activities, through: :user_activities
  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true
  validates :description, presence: true, length: { minimum: 15 }
