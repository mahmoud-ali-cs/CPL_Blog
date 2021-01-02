class Api::V1::PostsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_post, only: [:show, :update]
  authorize_resource
  skip_forgery_protection

  def index
    @posts = Post.all
    
    return render json: {
      posts: ActiveModelSerializers::SerializableResource.new(
        @posts, each_serializer: PostSerializer
      )
    }, status: :ok
  end

  def show
    unless @post.present?
      return render_error "post not found", :unprocessable_entity
    end

    return render json: {
      post: ActiveModelSerializers::SerializableResource.new(
        @post, serializer: PostSerializer, include: [:comments]
      )
    }, status: :ok
  end

  def create
    @post = Post.new post_params
    @post.user = current_api_v1_user

    if @post.save
      return render json: {
        post: ActiveModelSerializers::SerializableResource.new(
          @post, serializer: PostSerializer, include: [:comments]
        )
      }, status: :ok
    else
      return render_model_errors @post
    end
  end

  def update
    unless @post.present?
      return render_error "post not found", :unprocessable_entity
    end
    
    if @post.update post_params
      return render json: {
        post: ActiveModelSerializers::SerializableResource.new(
          @post, serializer: PostSerializer, include: [:comments]
        )
      }, status: :ok
    else
      return render_model_errors @post
    end
  end
  
  private
    def post_params
      params.require(:post).permit(
        :title, :body, :all_tags
      )
    rescue ActionController::ParameterMissing
      {}
    end

    def set_post
      @post = Post.find params[:id]
    rescue ActiveRecord::RecordNotFound
      @post = nil
    end

end
