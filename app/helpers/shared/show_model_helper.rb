module Shared
  module ShowModelHelper
    class ShowModelPresenter
      include Rails.application.routes.url_helpers
      include ActionView::Helpers::UrlHelper

      def initialize(model, options, params)
        @model = model
        @options = options || {}
        @params = params

        @options[:actions] ||= []
      end

      def link(child_model)
        path = path(child_model)
        link_to "View #{child_model.name.to_s.humanize}", path if path
      end

      def path(child_model)

        begin
        if @params[:course_id]
          if @model.class.name == "Course"
            polymorphic_path([Course.find(@params[:course_id]), child_model.name])
          else
            polymorphic_path([Course.find(@params[:course_id]), child_model.name],
                             {
                               "q[#{child_model.options.dig(:through) ? child_model.options.dig(:through).to_s.singularize + '_' : ''}" +
                                 "#{@model.class.name.underscore}_id_eq]" => @model.id })
          end
        elsif @params[:user_id]
          if @model.class.name == "User"
            polymorphic_path([User.find(@params[:user_id]), child_model.name])
          else
            polymorphic_path([User.find(@params[:user_id]), child_model.name],
                             {
                               "q[#{child_model.options.dig(:through) ? child_model.options.dig(:through).to_s.singularize + '_' : ''}" +
                                 "#{@model.class.name.underscore}_id_eq]" => @model.id })
          end
        end
        rescue NoMethodError
        end
      end

      def models_from_has_many
        models_by_relation(:has_many)
      end

      def models_from_has_one
        models_by_relation(:has_one)
      end

      def models_from_habtm
        models_by_relation(:has_and_belongs_to_many)
      end

      def models_from_belongs_to
        models_by_relation(:belongs_to)
      end

      private

      def models_by_relation(relation)
        [relation]
          .collect { |s| @model.class.reflect_on_all_associations(s) }
          .flatten
        #.reject { |v| options&.dig(:except)&.include? v.name.to_sym }
      end

    end
  end
end