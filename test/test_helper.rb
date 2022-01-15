# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/test_unit"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    include Devise::Test::IntegrationHelpers

    parallelize_setup do |worker|
      Searchkick.index_suffix = worker

      # reindex models
      Tag.reindex
      Question.reindex
      Enrollment.reindex
      QuestionState.reindex
      Courses::Registration.reindex

      # and disable callbacks
      Searchkick.disable_callbacks
    end

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    def method_missing(symbol, *args)
      raise StandardError.new("Missing method '#{symbol}'")
    end

    def self.let!(name, &block)
      let(name, &block)
      before do
        send(name)
      end
    end

    def self.with_roles_should(msg, *roles, &block)
      roles.each do |role|
        context role do
          it msg do
            create(:enrollment, user: user, role: create(:role, role, resource: course))
            instance_exec(&block)
          end
        end
      end
    end

    def self.with_roles_should_ctxt(*roles, &block)
      roles.each do |role|
        context role do
          let(:enrollment) { create(:enrollment, user: user, role: create(:role, role, resource: course)) }

          before do
            enrollment
          end

          instance_exec(&block)
        end
      end
    end

    def self.unauthorized_with_roles(*roles, &block)
      roles.each do |role|
        context role do
          it "not access" do
            create(:enrollment, user: user, role: create(:role, role, resource: course))
            instance_exec(&block)
            assert_response :unauthorized
          end
        end
      end
    end
  end
end
