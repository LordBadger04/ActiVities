class EventMembershipsController < ApplicationController
  def index
    @event = Event.find(params[:event_id])
    @event_memberships = @event.event_memberships
  end

  def create
    @event = Event.find(params[:event_id])
    @event_membership = @event.event_memberships.new(user: current_user, is_admin: false, status: "Pending")
    if @event_membership.save!
      @chat = @event.chat
      @message = @chat.messages.create(content: current_user.profile.username,
                                       user: current_user)
      redirect_to event_path(@event)
    else
      render "events/show", status: :unprocessable_entity
    end
  end

  def edit
    @event = Event.find(params[:event_id])
    @event_membership = @event.event_memberships.find(params[:id])
  end

  def update
    @event = Event.find(params[:event_id])
    @event_membership = @event.event_memberships.find(params[:id])
    @event_membership.update(event_membership_params)
    redirect_to event_path(@event)
  end

  private

  def event_membership_params
    params.require(:event_membership).permit(:is_admin, :status)
  end
end
