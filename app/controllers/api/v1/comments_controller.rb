class Api::V1::CommentsController < ApplicationController
  before_action :authenticate_api_v1_user!
  before_action :set_comment, only: [:update]
  authorize_resource
  skip_forgery_protection

  def create
    @post = Post.find_by id: params[:post_id]
    unless @post.present?
      return render_error "post not found", :unprocessable_entity
    end

    @comment = Comment.new comment_params
    @comment.post = @post
    @comment.user = current_api_v1_user

    if @comment.save
      return render json: {}, status: :ok
    else
      return render_model_errors @comment
    end
  end

  def update
    unless @comment.present?
      return render_error "comment not found", :unprocessable_entity
    end
    
    if @comment.update comment_params
      return render json: {}, status: :ok
    else
      return render_model_errors @comment
    end
  end
  
  private
    def comment_params
      params.require(:comment).permit(
        :body
      )
    rescue ActionController::ParameterMissing
      {}
    end

    def set_comment
      @comment = Comment.find params[:id]
    rescue ActiveRecord::RecordNotFound
      @comment = nil
    end

end
