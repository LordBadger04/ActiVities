class ProfilesController < ApplicationController
  def show
    @profile = Profile.find(params[:id])
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user
    if @profile.save!
      # user_activities = params[:profile][:user_activities_attributes]
      # user_activities.each_value do |value|
      #   new_activity = UserActivity.new
      #   new_activity.level = value[:level]
      #   new_activity.activity = Activity.find(value[:activity].to_i)
      #   new_activity.profile = @profile
      #   render :new, status: :unprocessable_entity unless new_activity.save!
      # end
      redirect_to profile_path(@profile)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @profile = Profile.find(params[:id])
  end

  def update
    @profile = Profile.update(profile_params)
    if @profile.save!
      redirect_to profile_path(@chat)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :age, :location,
                                    :gender, :username, :description, :language,
                                    user_activities_attributes: [:activity_id, :level, :_destroy])
  end
end
