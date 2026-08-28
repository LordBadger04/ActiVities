class ChatsController < ApplicationController
  def index
    @chats = current_user.events.map do |event|
      event.chat
    end
  end

  def show
    @chat = Chat.find(params[:id])
    @current_user_event_membership = EventMembership.find_by(user: current_user)
  end
end
