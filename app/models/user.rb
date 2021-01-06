# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  address                :string
#  allow_password_change  :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  gender                 :integer
#  last_name              :string
#  phone                  :string
#  provider               :string           default("email"), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string           default(""), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :validatable
  include DeviseTokenAuth::Concerns::User

    # Associations
    has_many :posts, dependent: :destroy
    has_many :comments, dependent: :destroy
    # has_many :followers, class_name: 'Following', foreign_key: 'followed_id'
    # has_many :following, class_name: 'Following', foreign_key: 'followed_id'

    has_many :active_relationships, class_name:  "Following",
        foreign_key: "follower_id",
        inverse_of: :follower,
        dependent: :destroy
    has_many :passive_relationships, class_name: "Following",
        foreign_key: "followed_id",
        inverse_of: :followed,
        dependent: :destroy

    has_many :followings, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower

    # Query Interface
    # -Enums
    enum gender: {male: 0, female: 1}
  
    # -Scopes
  
    # Validations
    #--password
    PASSWORD_FORMAT = /\A
      (?=.{8,})          # Must contain 8 or more characters
      (?=.*\d)           # Must contain a digit
      (?=.*[a-z])        # Must contain a lower case character
      (?=.*[A-Z])        # Must contain an upper case character
      (?=.*[[:^alnum:]]) # Must contain a symbol
    /x.freeze
  
    validates :password,
              presence: true,
              length: { in: Devise.password_length },
              format: { with: PASSWORD_FORMAT },
              confirmation: true,
              on: :create, if: -> { self.provider == "email" }
  
    validates :password,
              allow_nil: true,
              length: { in: Devise.password_length },
              format: { with: PASSWORD_FORMAT },
              confirmation: true,
              on: :update, if: -> { self.provider == "email" }
  
    #--first_name & last_name
    validates :first_name, :last_name, presence: true, length: { minimum: 2 }
  
    validate :gender_should_be_valid


    def gender=(value)
      super value
      @gender_backup = nil
    rescue ArgumentError => exception
      error_message = 'is not a valid gender'
      if exception.message.include? error_message
        @gender_backup = value
        self[:gender] = nil
      else
        raise
      end
    end


    private

    def gender_should_be_valid
      if @gender_backup
        self.gender ||= @gender_backup
        error_message = 'is not a valid gender'
        errors.add(:gender, error_message)
      end
    end
end
