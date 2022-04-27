class BaseAbility
  include CanCan::Ability


  def initialize(user, context)
    @user = user
    @context = context
  end

  private

  attr_accessor :user, :context
end
