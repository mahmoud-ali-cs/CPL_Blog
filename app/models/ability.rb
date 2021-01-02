# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)

    if user.present?
      # => User
      can :read, User
      can :update, User, id: user.id

      
    end

  end
end
