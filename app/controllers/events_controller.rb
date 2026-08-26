class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    if @event.save!
      @event_membership = @event.event_memberships.create(user: current_user, is_admin: true, status: "Accepted")
      # @event_membership.event = @event
      # @event_membership.user = current_user
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

  private

  def event_params
    params.require(:event).permit(:title, :description, :max_participant,
                                  :location, :start_date, :end_date, :event_date, :activity_id)
  end
end
