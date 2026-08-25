# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning activities..."

Activity.destroy_all

puts "Creating activities..."

activities = [
  # Sport
  { name: "Football", genre: "Sport" },
  { name: "Basketball", genre: "Sport" },
  { name: "Tennis", genre: "Sport" },
  { name: "Running", genre: "Sport" },
  { name: "Cycling", genre: "Sport" },
  { name: "Swimming", genre: "Sport" },
  { name: "Hiking", genre: "Sport" },
  { name: "Climbing", genre: "Sport" },
  { name: "Padel", genre: "Sport" },
  { name: "Yoga", genre: "Sport" },

  # Culture
  { name: "Cinema", genre: "Culture" },
  { name: "Museum", genre: "Culture" },
  { name: "Exhibition", genre: "Culture" },
  { name: "Theater", genre: "Culture" },
  { name: "Concert", genre: "Culture" },
  { name: "Photography", genre: "Culture" },
  { name: "Book Club", genre: "Culture" },
  { name: "Street Art", genre: "Culture" },
  { name: "History Tour", genre: "Culture" },
  { name: "Creative Workshop", genre: "Culture" },

  # Relaxing
  { name: "Picnic", genre: "Relaxing" },
  { name: "Coffee", genre: "Relaxing" },
  { name: "Brunch", genre: "Relaxing" },
  { name: "Board Games", genre: "Relaxing" },
  { name: "Meditation", genre: "Relaxing" },
  { name: "Spa", genre: "Relaxing" },
  { name: "Walk", genre: "Relaxing" },
  { name: "Beach Day", genre: "Relaxing" },
  { name: "Cooking", genre: "Relaxing" },
  { name: "Gaming", genre: "Relaxing" }
]

activities.each do |activity|
  Activity.create!(activity)
end

puts "#{Activity.count} activities created!"
