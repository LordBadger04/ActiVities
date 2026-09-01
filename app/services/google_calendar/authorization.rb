module GoogleCalendar
  class Authorization
    TOKEN_URI = "https://oauth2.googleapis.com/token".freeze

    def initialize(user)
      @user = user
    end

    def client
      raise NotConnected if @user.google_refresh_token.blank?

      refresh! if expired?
      signet
    end

    private

    def signet
      @signet ||= Signet::OAuth2::Client.new(
        client_id: Rails.application.credentials.dig(:google, :client_id),
        client_secret: Rails.application.credentials.dig(:google, :client_secret),
        token_credential_uri: TOKEN_URI,
        access_token: @user.google_token,
        refresh_token: @user.google_refresh_token,
        expires_at: @user.google_token_expires_at
      )
    end

    def expired?
      @user.google_token_expires_at.nil? ||
        @user.google_token_expires_at <= 2.minutes.from_now
    end

    def refresh!
      signet.refresh!
      @user.update!(
        google_token: signet.access_token,
        google_token_expires_at: signet.expires_at
      )
    end
  end
end
