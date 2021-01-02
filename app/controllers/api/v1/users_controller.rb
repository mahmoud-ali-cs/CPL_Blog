class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_v1_user!, only: [:index, :show, :update]
  before_action :set_user, only: [:show, :update]
  authorize_resource only: [:index, :show, :update]

  def sign_up
    @user = User.new sign_up_params

    if @user.save
      render_success
    else
      return render_model_errors @user
    end
  end

  def login
    field = sign_in_params.keys.map(&:to_sym).first

    @user = nil
    if field
      email_value = sign_in_params[:email].downcase.strip

      @user = find_user email_value
    end

    if @user && sign_in_params[:email].present? && sign_in_params[:password].present?
      valid_password = @user.valid_password?(sign_in_params[:password])

      if !valid_password
        return render_error I18n.t('devise_token_auth.sessions.bad_credentials'), :unauthorized
        # return render_create_error_bad_credentials
      end
      
      token = DeviseTokenAuth::TokenFactory.create

      # store client + token in user's token hash
      @user.tokens[token.client] = {
        token:  token.token_hash,
        expiry: token.expiry
      }

      # clean_old_tokens
      @user.save

      # Now we have to pretend like an API user has already logged in.
      # (When the user actually logs in, the server will send the user
      # - assuming that the user has  correctly and successfully logged in
      # - four auth headers. We are to then use these headers to access
      # things which are typically restricted
      # The following assumes that the user has received those headers
      # and that they are then using those headers to make a request
    
      new_auth_header = @user.build_auth_header(token.token, token.client)
    
      puts 'This is the new auth header'
      puts new_auth_header.to_s
    
      # update response with the header that will be required by the next request
      puts response.headers.merge!(new_auth_header).to_s

      render_success

    else
      return render_error I18n.t('devise_token_auth.sessions.bad_credentials'), :unauthorized
    end
  end

  def update
    unless @user.present?
      return render_error "user not found", :unprocessable_entity
    end

    if @user.update update_params
      render_success
    else
      return render_model_errors @user
    end
  end

  def show
    unless @user.present?
      return render_error "user not found", :unprocessable_entity
    end

    render_success
  end

  def index
    @users = User.all

    render json: {
      user: ActiveModelSerializers::SerializableResource.new(
        @users, each_serializer: UserSerializer
      )
    }, status: :ok
  end


  private

  def sign_up_params
    params.require(:user).permit(
      :email, :phone, :address, :password, :password_confirmation,
      :first_name, :last_name, :gender
    )
  rescue ActionController::ParameterMissing
    {}
  end

  def update_params
    params.require(:user).permit(
      :first_name, :last_name, :address, :gender
    )
  rescue ActionController::ParameterMissing
    {}
  end

  def sign_in_params
    params.require(:user).permit(
      :email, :password
    )
  rescue ActionController::ParameterMissing
    {}
  end

  def set_user
    @user = User.find params[:id]
  rescue ActiveRecord::RecordNotFound
    {}
  end

  def render_create_error_bad_credentials
    render json: {
      errors: {
        full_messages: [I18n.t('devise_token_auth.sessions.bad_credentials')]
      }
    }, status: :unauthorized
  end

  # def render_error_not_confirmed attribute
  #   render json: {
  #     errors: {
  #       full_messages: ["#{attribute} not verified"]
  #     }
  #   }, status: :bad_request
  # end

  def find_user value
    @user = User.where(
      ['lower(email) = :value', { value: value.strip.downcase }]
    ).first
  end

  def render_success
    render json: {
      user: ActiveModelSerializers::SerializableResource.new(
        @user, serializer: UserSerializer
      )
    }, status: :ok
  end

  def clean_old_tokens
    if @user.tokens.present? && max_client_tokens_exceeded?
      # Using Enumerable#sort_by on a Hash will typecast it into an associative
      #   Array (i.e. an Array of key-value Array pairs). However, since Hashes
      #   have an internal order in Ruby 1.9+, the resulting sorted associative
      #   Array can be converted back into a Hash, while maintaining the sorted
      #   order.
      @user.tokens = @user.tokens.sort_by { |_cid, v| v[:expiry] || v['expiry'] }.to_h

      # Since the tokens are sorted by expiry, shift the oldest client token
      #   off the Hash until it no longer exceeds the maximum number of clients
      @user.tokens.shift while max_client_tokens_exceeded?
    end
  end

  def max_client_tokens_exceeded?
    @user.tokens.length > DeviseTokenAuth.max_number_of_devices
  end

  def set_user
    @user = User.find params[:id]
  rescue ActiveRecord::RecordNotFound
    @user = nil
  end

end
