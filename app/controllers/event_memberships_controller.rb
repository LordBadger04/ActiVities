class EventMembershipsController < ApplicationController
  def index
    @event_memberships = EventMembership.all
  end

  def create
    @event = Event.find(params[:event_id])
    @event_membership = EventMembership.new(event_membership_params)
    @event_membership.event = @event
    if @event_membership.save!
      redirect_to event_path(@event)
    else
      render "events/show", status: :unprocessable_entity
    end
  end

  def edit
    @event = Event.find(params[:event_id])
    @event_membership = EventMembership.find(params[:id])
  end

  def update
    @event = Event.find(params[:event_id])
    @event_membership = EventMembership.update(event_membership_params)
    if @event_membership.save!
      redirect_to event_path(@event)
    else
      render "events/show", status: :unprocessable_entity
    end
  end

  private

  def event_membership_params
    params.require(:event_membership).permit(:status, :is_admin)
  end
end
