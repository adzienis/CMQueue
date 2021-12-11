class Courses::UpdateFeedJob < ApplicationJob
  queue_as :course_queue

  def perform(course:)
    tag_staff_h = course.connected_staff.map { |v| [v.selected_tags, v] }.collect_entries
    elastic_tag_h = tag_staff_h.keys.map { |tags| [tags, Search::FeedSearch.new(params: {tags: tags}, course: course).search] }.collect_entries

    tag_staff_h.each do |k, v|
      v.each do |staff|
        component = Courses::Feed::FeedComponent.new(course: course,
          search: elastic_tag_h[k][1],
          pagy: elastic_tag_h[k][0],
          options: {
            where: {
              tags: k
            }
          },
          selected_tags: k)

        SyncedTurboChannel.broadcast_replace_later_to staff.user,
          target: "feed-component",
          html: ApplicationController.render(component, layout: false)
      end
    end
  end
end
