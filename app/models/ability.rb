# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    if user.present?
      # => User
      can :read, User
      can :update, User, id: user.id

      # => Post
      can :read, Post
      can :create, Post
      can :update, Post, user_id: user.id

      # => Comment
      can :create, Comment
      can :update, Comment, user_id: user.id
      
      # => Following
      can :follow, Following
      can :unfollow, Following, follower_id: user.id
      can :show_followers, Following
      can :show_followings, Following

    end

  end
end
