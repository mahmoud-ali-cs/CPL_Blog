Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'user_auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'user_auth', controllers: {
        # token_validations:  'overrides/token_validations',
        # confirmations:      'user/confirmations',
        # passwords:          'user/passwords',
        # omniauth_callbacks: 'user/omniauth_callbacks',
        registrations: 'user/registrations',
        sessions: 'user/sessions'
        # token_validations:  'user/token_validations'
      }

      resources :users, only: [:index, :show, :update]
      resources :posts, only: [:index, :show, :update, :create] do
        resources :comments, only: [:update, :create], shallow: true
      end

      post 'users/sign_up', to: 'users#sign_up',
        as: "sign_up"

      post 'users/sign_in', to: 'users#login',
        as: "sign_in"

    end
  end
  
end
