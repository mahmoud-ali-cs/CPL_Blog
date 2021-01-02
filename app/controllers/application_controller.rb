class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  require 'cancan'

  protect_from_forgery unless: -> { request.format.json? }

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    render_error "your are not authorized to access this page", :unauthorized
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_api_v1_user)
  end

  protected

  def render_authenticate_error
    return render json: {
      errors: { full_messages: [I18n.t('devise.failure.unauthenticated')] }
    }, status: :unauthorized
  end

  def render_model_errors model
    render json: {
      errors: model.errors.to_hash.merge(full_messages: model.errors.full_messages)
    }, status: :unprocessable_entity
  end

  def render_error message, status
    return render json: {
      errors: { full_messages: [message] }
    }, status: status
  end
  
end
