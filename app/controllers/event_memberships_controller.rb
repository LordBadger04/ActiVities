class EventMembershipsController < ApplicationController
  def index
    @event_memberships = EventMembership.all
  end

  def create
    @event = Event.find(params[:event_id])
    @event_membership = EventMembership.new(user: current_user, is_admin: false, status: "Pending")
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
end
