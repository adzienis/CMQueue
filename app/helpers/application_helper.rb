require 'action_view'

module UrlHelpers

  extend ActiveSupport::Concern

  class Base
    include Rails.application.routes.url_helpers

    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end

  def url_helpers
    @url_helpers ||= UrlHelpers::Base.new
  end

  def self.method_missing method, *args, &block
    @url_helpers ||= UrlHelpers::Base.new

    if @url_helpers.respond_to?(method)
      @url_helpers.send(method, *args, &block)
    else
      super method, *args, &block
    end
  end

end

module ApplicationHelper
  include Pagy::Frontend
  extend ActiveModel::Model

  class SearchClass
    include UrlHelpers

    def initialize
      super
    end

    public

    def self.fetch_attribute(instance, hash)
      if hash.nil?
        return nil
      end

      k, v = hash.first

      case v
      when Hash
        self.fetch_attribute(instance.send(k), v)
      when Symbol
        instance.send(k).send(v)
      else
        nil
      end
    end

    def self.gen_course_link(instance_model, association)
      ass = instance_model.class.reflect_on_association(association)
      if ass.options.dig(:through)
        UrlHelpers.polymorphic_url([instance_model, ass.klass], only_path: true, q: { "#{ass.options.dig(:through)}_course_id_eq": instance_model.id })
      else
        UrlHelpers.polymorphic_url([instance_model, ass.klass], only_path: true, q: { "course_id_eq": instance_model.id })
      end
    end
  end
end
