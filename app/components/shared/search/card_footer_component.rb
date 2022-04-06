class Shared::Search::CardFooterComponent < ViewComponent::Base
  def initialize(record:, course:, options: {})
    @course = course
    @record = record
    @options = options
  end

  def actions
    options[:actions]
  end

  def edit?
    helpers.can?(:edit, record) && !(actions.present? && actions.exclude?(:edit))
  end

  def destroy?
    helpers.can?(:destroy, record) && !(actions.present? && actions.exclude?(:destroy))
  end

  def audit?
    helpers.can?(:audit, record) && !(actions.present? && actions.exclude?(:audit))
  end
  private

  attr_reader :record, :course, :options
end
