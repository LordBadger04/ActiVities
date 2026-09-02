class ChatsController < ApplicationController
  def index
    @chats = current_user.chats.distinct
  end

  def show
    @chat = Chat.find(params[:id])
    @message = Message.new
    @event = @chat.event
    @current_user_event_membership = EventMembership.find_by(user: current_user)
  end
end
