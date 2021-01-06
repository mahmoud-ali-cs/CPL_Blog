class Api::V1::FollowingsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_followed_user, only: [:follow, :unfollow]
  before_action :set_user, only: [:show_followers, :show_followings]
  authorize_resource
  skip_forgery_protection

  def follow
    # /api/v1/users/:id/follow
    unless @followed_user.present?
      return render_error "user not found", :unprocessable_entity
    end

    unless current_api_v1_user != @followed_user
      return render_error "you can't follow yourself", :unprocessable_entity
    end

    @following = Following.new followed: @followed_user, follower: current_api_v1_user

    if @following.save
      render json: {}, status: :ok
    else
      return render_model_errors @following
    end
  end

  def unfollow
    # /api/v1/users/:id/unfollow
    unless @followed_user.present?
      return render_error "user not found", :unprocessable_entity
    end

    @following = Following.where(followed: @followed_user, follower: current_api_v1_user).first

    unless @following.present?
      return render_error "following relation not found", :unprocessable_entity
    end

    if @following.destroy
      render json: {}, status: :ok
    else
      return render_model_errors @following
    end
  end

  def show_followers
    # /api/v1/users/:id/followers
    unless @user.present?
      return render_error "user not found", :unprocessable_entity
    end

    render json: {
      followers: ActiveModelSerializers::SerializableResource.new(
        @user.followers, each_serializer: UserSerializer
      )
    }, status: :ok
  end

  def show_followings
    # /api/v1/users/:id/followings
    unless @user.present?
      return render_error "user not found", :unprocessable_entity
    end

    render json: {
      followings: ActiveModelSerializers::SerializableResource.new(
        @user.followings, each_serializer: UserSerializer
      )
    }, status: :ok
  end
  
  private

  def set_followed_user
    @followed_user = User.find params[:id]
  rescue ActiveRecord::RecordNotFound
    @followed_user = nil
  end

  def set_user
    @user = User.find params[:id]
  rescue ActiveRecord::RecordNotFound
    @user = nil
  end

end
