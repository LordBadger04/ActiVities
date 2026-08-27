class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if params[:latitude].present? && params[:longitude].present?
      @events = Event.near(
        [params[:latitude], params[:longitude]],
        25,
        units: :km
      )
    else
      @events = Event.order(created_at: :desc).limit(3)
    end
  end
end
