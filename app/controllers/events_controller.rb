class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  def index
    @events = Event.all

    if params[:latitude].present? &&
      params[:longitude].present?

      radius = params[:radius].presence || 25

      @events = Event.near(
        [params[:latitude], params[:longitude]],
        radius.to_i,
        units: :km
      )
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
    @current_user_event_membership = EventMembership.find_by(user: current_user)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    if @event.save!
      @event_membership = @event.event_memberships.create(user: current_user, is_admin: true, status: "Accepted")
      @chat = Chat.new
      @chat.event = @event
      render :new, status: :unprocessable_entity unless @chat.save!
      redirect_to event_path(@event)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @event = Event.find(params[:id])
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

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_path, status: :see_other
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :max_participant,
                                  :location, :start_date, :end_date, :event_date, :activity_id)
  end
end
