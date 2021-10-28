class Shared::Models::Show::CardFooterComponent < ViewComponent::Base
  def initialize(record:, course:)
    @course = course
    @record = record
  end

  private

  attr_reader :record, :course
end
