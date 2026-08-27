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
      redirect_to profile_path(@profile)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @profile = Profile.find(params[:id])
  end

  def update
    @profile = Profile.find(params[:id])
    @profile.update(profile_params)
    redirect_to profile_path(@profile)
    # if @profile.save!
    #   redirect_to profile_path(@chat)
    # else
    #   render :edit, status: :unprocessable_entity
    # end
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :last_name, :photo, :age, :location,
                                    :gender, :username, :description, :language,
                                    user_activities_attributes: [:id, :activity_id, :level, :_destroy])
  end
end
