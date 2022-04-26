class BaseAbility
  include CanCan::Ability


  def initialize(user, context)
  end

  private

  attr_accessor :user
end
