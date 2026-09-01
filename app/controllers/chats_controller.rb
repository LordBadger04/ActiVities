class ChatsController < ApplicationController
  def index
    @chats = current_user.chats
  end

  def show
    @chat = Chat.find(params[:id])
    @event = @chat.event
    @current_user_event_membership = EventMembership.find_by(user: current_user)
  end

  def redirect
    client = Signet::OAuth2::Client.new(client_options)

    redirect_to client.authorization_uri.to_s, allow_other_host: true
  end

  private

  def client_options
    {
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      authorization_uri: 'https://google.com',
      token_credential_uri: 'https://googleapis.com',

      scope: ['https://www.googleapis.com/auth/calendar'],

      redirect_uri: callback_url
    }
  end
end
