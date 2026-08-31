class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  def index
    filtered_activities = current_user.profile.user_activities.map(&:activity)
    @events = Event.where(activity: filtered_activities).where(status: "Coming")
    if params[:latitude].present? && params[:longitude].present?

      user_coordinates = [
        params[:latitude].to_f,
        params[:longitude].to_f
      ]

      if params[:radius].present?
        @events = Event.near(
          user_coordinates,
          params[:radius].to_i,
          units: :km
        )
      end

      @distances = {}

      @events.each do |event|
        next if event.latitude.blank? || event.longitude.blank?

        @distances[event.id] =
          Geocoder::Calculations.distance_between(
            user_coordinates,
            [event.latitude, event.longitude],
            units: :km
          )
      end
    end

    if params[:genre].present?
      @events = @events.joins(:activity)
                       .where(activities: { genre: params[:genre] })
    end

    if user_signed_in? && current_user.profile.present?
      preferred_activity_ids =
        current_user.profile.user_activities.pluck(:activity_id)

      @recommended_events =
        @events.where(activity_id: preferred_activity_ids)

      @other_events =
        @events.where.not(activity_id: preferred_activity_ids)
    end
  end

  def show
    @event = Event.find(params[:id])

    @current_user_event_membership =
      EventMembership.find_by(user: current_user, event: @event)

    @can_view_exact_location =
      user_signed_in? &&
      (
        @event.user == current_user ||
        @current_user_event_membership&.is_admin ||
        @current_user_event_membership&.status == "Accepted"
      )

    if params[:latitude].present? &&
      params[:longitude].present? &&
      @event.latitude.present? &&
      @event.longitude.present?

      @distance = Geocoder::Calculations.distance_between(
        [params[:latitude].to_f, params[:longitude].to_f],
        [@event.latitude, @event.longitude],
        units: :km
      )
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.status = "Coming"
    @event.user = current_user
    if @event.save!
      @event_membership = @event.event_memberships.create(user: current_user, is_admin: true, status: "Accepted")
      @chat = Chat.new
      @chat.event = @event
      render :new, status: :unprocessable_entity unless @chat.save!
      @launch_message = @chat.messages.create(user: current_user, content: "You've created the event", chat: @chat)
      redirect_to event_path(@event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def cancel
    @event = Event.find(params[:id])
    @event.status = "Canceled"
    @event.save!
    redirect_to event_path(@event)
  end

  def update
    @event = Event.find(params[:id])
    @event.update(event_params)
    if @event.save!
      redirect_to event_path(@event)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def history
    @events = current_user.events.where(status: "Canceled")
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :max_participant,
                                  :location, :start_date, :end_date, :event_date, :activity_id)
  end
end
