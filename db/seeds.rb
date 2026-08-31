# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

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
  { name: "Walk", genre: "Relaxing" },
  { name: "Beach Day", genre: "Relaxing" },
  { name: "Cooking", genre: "Relaxing" },
  { name: "Gaming", genre: "Relaxing" }
]

activities.each do |activity|
  record = Activity.find_or_initialize_by(name: activity[:name])
  record.genre = activity[:genre]
  record.save!
end

puts "#{Activity.count} activities created!"

puts "Attaching activity images..."

activity_images = {
  # Sport
  "Football" => "sport/football.png",
  "Basketball" => "sport/basketball.png",
  "Tennis" => "sport/tennis.png",
  "Running" => "sport/running.png",
  "Cycling" => "sport/cycling.png",
  "Swimming" => "sport/swimming.png",
  "Hiking" => "sport/hiking.png",
  "Climbing" => "sport/climbing.png",
  "Padel" => "sport/padel.png",
  "Yoga" => "sport/yoga.png",

  # Culture
  "Cinema" => "culture/cinema.png",
  "Museum" => "culture/museum.png",
  "Exhibition" => "culture/exhibition.png",
  "Theater" => "culture/theater.png",
  "Concert" => "culture/concert.png",
  "Photography" => "culture/photography.png",
  "Book Club" => "culture/book_club.png",
  "Street Art" => "culture/street_art.png",
  "History Tour" => "culture/history_tour.png",
  "Creative Workshop" => "culture/creative_workshop.png",

  # Relaxing
  "Picnic" => "relaxing/picnic.png",
  "Coffee" => "relaxing/coffee.png",
  "Brunch" => "relaxing/brunch.png",
  "Board Games" => "relaxing/board_games.png",
  "Meditation" => "relaxing/meditation.png",
  "Walk" => "relaxing/walk.png",
  "Beach Day" => "relaxing/beach_day.png",
  "Cooking" => "relaxing/cooking.png",
  "Gaming" => "relaxing/gaming.png"
}

activity_images.each do |activity_name, image_path|
  activity = Activity.find_by(name: activity_name)

  next if activity.photo.attached?

  full_path = Rails.root.join(
    "app/assets/images/activities",
    image_path
  )

  unless File.exist?(full_path)
    puts "⚠️ Missing image: #{image_path}"
    next
  end

  activity.photo.attach(
    io: File.open(full_path),
    filename: File.basename(full_path),
    content_type: "image/png"
  )

  puts "✅ #{activity_name}"
end

puts "Activity images attached!"
