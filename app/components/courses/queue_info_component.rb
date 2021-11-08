class Course::QueueInfoComponent < ViewComponent::Base
  def initialize(info:, title:, footer:, value:)
    @info = info
    @title = title
    @footer = footer
    @value = value
  end

  private

  attr_reader :info, :title, :footer, :value
end