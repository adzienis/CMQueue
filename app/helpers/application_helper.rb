# frozen_string_literal: true

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

  def self.method_missing(method, *args, &block)
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

  def self.QuestionsPerTa

    query = ->(state) do
      QuestionState.where("question_id = questions.id")
                   .where("enrollment_id = enrollments.id")
                   .where(state: state)
    end

    Enrollment.undiscarded.with_course_roles(:instructor, :ta).joins(:question_states, question_states: :question)
              .merge(Question.where(id: Question.questions_by_state(:resolved).with_today))
              .group(["enrollments.id", "questions.id"])
              .select("enrollments.id as enrollment_id, questions.id as question_id, avg((#{QuestionState
                                                                                              .where(id: query.call("resolved").select("max(question_states.id)"))
                                                                                              .select(:created_at).to_sql})
                                - (#{QuestionState.where(id: query.call("resolving").select("min(question_states.id)"))
                                                  .select(:created_at).to_sql}))")
  end

  def self.get_associations(model)
    [:has_many, :belongs_to, :has_one]
      .collect { |s| model.reflect_on_all_associations(s) }
      .flatten
  end

  class SearchClass
    include UrlHelpers

    def self.fetch_attribute(instance, hash)
      if hash.nil?
        return nil
      elsif instance.is_a?(ActiveRecord::Associations::CollectionProxy) && hash.instance_of?(Symbol)
        return instance.map { |v| v.send(hash) }.join(', ')
      elsif hash.instance_of? Symbol
        return instance.send(hash)
      end

      k, v = hash.first

      case v
      when Hash
        fetch_attribute(instance.send(k), v)
      when Symbol
        result = instance.send(k) #.send(v)
        fetch_attribute(result, v)
      end
    end

    def self.gen_course_link(instance_model, association)
      ass = instance_model.class.reflect_on_association(association)
      if ass.options[:through]
        UrlHelpers.polymorphic_url([instance_model, ass.klass], only_path: true,
                                   q: { "#{ass.options[:through]}_course_id_eq": instance_model.id })
      else
        UrlHelpers.polymorphic_url([instance_model, ass.klass], only_path: true,
                                   q: { "course_id_eq": instance_model.id })
      end
    end
  end

  def flatten_hash(collection)

    flat = collection.flatten

    flat = flat.map do |v|
      case v
      when Hash
        flatten_hash(v)
      else
        v
      end
    end

    flat.flatten

  end

  def to_csv(hash, records, model)
    asses = hash.keys.filter { |v| hash[v].is_a? Hash }
    full_asses = asses.collect { |u| { u => hash[u].keys.filter { |x| hash[u][x] == "1" } } }.flatten
    attribs = hash.keys.filter { |v| !hash[v].is_a?(Hash) && hash[v] == "1" }

    names = attribs + (full_asses.collect { |x| x.values.first.collect { |v| "#{x.keys.first}_#{v}" } }.flatten)

    full_asses_dict = full_asses.inject(:merge)
    CSV.generate(headers: true) do |csv|
      csv << names

      records
        .as_json(
          include: [:has_and_belongs_to_many, :belongs_to, :has_one, :has_many]
                     .collect { |s| model.reflect_on_all_associations(s) }
                     .flatten
                     .collect(&:name)
                     .map { |s| { s => { only: full_asses_dict[s.to_s] } } }
        ).each do |x|
        attrib_values = x.values_at(*attribs)

        ass_values = full_asses.map do |z|
          k = z.keys.first

          if x[k].is_a? Array
            injected = x[k].flat_map(&:entries).group_by(&:first).map { |k, v| Hash[k, v.map(&:last)] }
            injected.map { |v| v.values.join(',') }.flatten
          else
            values = x[k].values
          end
        end.flatten

        csv << (attrib_values + ass_values)
      end
    end

  end
end


