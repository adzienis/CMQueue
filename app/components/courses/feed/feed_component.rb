module Courses
  module Feed
    class FeedComponent < ViewComponent::Base
      def initialize(course:, options: nil, search: nil, pagy: nil, selected_tags: [])
        super
        @course = course
        @options = options
        @selected_tags = selected_tags
        @search = search
        @pagy = pagy
      end

      def questions_msg
        if total_tag_count > 0
          "No questions with these tags, but there are still #{total_tag_count} questions"
        else
          "No questions left"
        end
      end

      def tags
        search.aggs["tags"]["buckets"].map { |k| k["key"] }
      end

      def available_tags
        course.available_tags
      end

      def questions
        @questions ||= search.results
      end

      def options
        return @options if @options.present?
        @options = {}
        @options[:where] = {}
        @options
      end

      def search
        return @search if @search.present?
        @pagy, @search = Search::FeedSearch.new(params: helpers.params.merge(options[:where]), course: course).search
        @search
      end

      def total_tag_count
        @total_tag_count ||= available_tags.map{|tag| tag_count(tag.name)}.sum
      end

      def tag_count(tag_name)
        bucket = bucket_for_tag(tag_name)

        bucket["doc_count"]
      end

      def bucket_for_tag(tag_name)
        search.aggs["tags"]["buckets"].find{|k| k["key"] == tag_name} || { "doc_count" => 0 }
      end

      def pagy
        return @pagy if @pagy.present?
        @pagy, @search = Search::FeedSearch.new(params: helpers.params.merge(options[:where]), course: course).search
        @pagy
      end

      private

      attr_reader :course, :selected_tags
    end
  end
end
