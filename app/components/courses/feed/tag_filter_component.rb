module Courses
  module Feed
    class TagFilterComponent < ViewComponent::Base
      def initialize(search:, course:)
        super
        @search = search
        @course = course
      end
      def tags
        search.aggs["tags"]["buckets"].map{|k| k["key"]}
      end

      def tag_count(tag_name)
        bucket = bucket_for_tag(tag_name)

        bucket["doc_count"]
      end

      def tag_label_method(tag_name)
        msg = tag_name
        msg = "#{msg} (1 question)" if tag_count(tag_name) == 1
        msg = "#{msg} (#{tag_count(tag_name)} questions)" if tag_count(tag_name) > 1 || tag_count(tag_name) == 0
        msg
      end

      def bucket_for_tag(tag_name)
        search.aggs["tags"]["buckets"].find{|k| k["key"] == tag_name}
      end

      private

      attr_reader :search, :course
    end
  end
end
