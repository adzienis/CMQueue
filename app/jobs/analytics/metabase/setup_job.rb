class Analytics::Metabase::SetupJob < ApplicationJob
  include Metabaseable

  queue_as :default

  def perform(course:)
    Analytics::Metabase::Collections::Create.new(name: course.name).call

    Analytics::Metabase::Cards::AddDefaultCardsToCourse.new(course: course).call
  end
end
