class EventMembershipsController < ApplicationController
  def index
    @event_memberships = EventMembership.all
  end

  def create
    @event = Event.find(params[:event_id])
    @event_membership = @event.event_memberships.new(user: current_user, is_admin: false, status: "Pending")
    if @event_membership.save!
      @chat = @event.chats
      @message = Message.create(content: "#{current_user.profile.username} sent you a request to join your activity")
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
