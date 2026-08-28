class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    if params[:query].present?
      @search_results =
        Event.joins(:activity)
             .where(
               "events.title ILIKE :q OR activities.name ILIKE :q",
               q: "%#{params[:query]}%"
             )
             .limit(6)
    else
      @search_results = Event.none
    end

    if params[:latitude].present? && params[:longitude].present?
      user_coordinates = [
        params[:latitude].to_f,
        params[:longitude].to_f
      ]

      @user_location = {
        latitude: user_coordinates[0].round(2),
        longitude: user_coordinates[1].round(2)
      }

      @nearby_events =
        Event.near(
          user_coordinates,
          50,
          units: :km
        ).limit(3)

      @distances = {}

      @nearby_events.each do |event|
        next if event.latitude.blank? || event.longitude.blank?

        @distances[event.id] =
          Geocoder::Calculations.distance_between(
            user_coordinates,
            [event.latitude, event.longitude],
            units: :km
          )
      end
    else
      @nearby_events = Event.order(created_at: :desc).limit(3)
      @distances = {}
    end

    if user_signed_in? && current_user.profile.present?
      preferred_activity_ids =
        current_user.profile.user_activities.pluck(:activity_id)

      @recommended_events =
        Event.where(activity_id: preferred_activity_ids)
             .where.not(id: @nearby_events.pluck(:id))
             .limit(3)

      @different_events =
        Event.where.not(activity_id: preferred_activity_ids)
             .where.not(id: @nearby_events.pluck(:id))
             .limit(3)
    else
      @recommended_events = Event.none

      @different_events =
        Event.order(created_at: :desc)
             .where.not(id: @nearby_events.pluck(:id))
             .limit(3)
    end

    map_events = (@nearby_events.to_a + @different_events.to_a).uniq

    @markers = map_events.filter_map do |event|
      next if event.latitude.blank? || event.longitude.blank?

      {
        id: event.id,
        title: event.title,
        latitude: event.latitude.round(2),
        longitude: event.longitude.round(2)
      }
    end
  end
end
