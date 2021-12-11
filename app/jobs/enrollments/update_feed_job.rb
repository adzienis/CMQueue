class Enrollments::UpdateFeedJob < ApplicationJob
  queue_as :default

  def perform(enrollment:)
    selected_tags = enrollment.selected_tags
    pagy, search = Search::FeedSearch.new(params: {tags: selected_tags}, course: enrollment.course).search

    component = Courses::Feed::FeedComponent.new(course: enrollment.course,
      search: search,
      pagy: pagy,
      options: {
        where: {
          tags: selected_tags
        }
      },
      selected_tags: selected_tags)

    SyncedTurboChannel.broadcast_replace_later_to enrollment.user,
      target: "feed-component",
      html: ApplicationController.render(component, layout: false)
  end
end
