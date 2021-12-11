module Courses
  module Feed
    class TagFilterComponent < ViewComponent::Base
      def initialize(search:, course:, selected_tags: [])
        super
        @search = search
        @course = course
        @selected_tags = selected_tags
      end

      def render?
        course.available_tags.exists?
      end

      def tags
        course.available_tags.map(&:name)
      end

      def tag_count(tag_name)
        bucket = bucket_for_tag(tag_name)

        bucket["doc_count"]
      end

      def bucket_for_tag(tag_name)
        search.aggs["tags"]["buckets"].find { |k| k["key"] == tag_name } || {"doc_count" => 0}
      end

      def tag_label_method(tag_name)
        msg = tag_name
        msg = "#{msg} (1 question)" if tag_count(tag_name) == 1
        msg = "#{msg} (#{tag_count(tag_name)} questions)" if tag_count(tag_name) > 1 || tag_count(tag_name) == 0
        msg
      end

      private

      attr_reader :search, :course, :selected_tags
    end
  end
end
