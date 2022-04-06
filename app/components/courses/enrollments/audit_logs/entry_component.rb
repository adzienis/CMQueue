module Courses
  module Enrollments
    module AuditLogs
      class EntryComponent < ViewComponent::Base
        def initialize(log:, index:)
          @log = log
          @index = index
        end

        private

        attr_accessor :log, :index

        def enrollment
          @enrollment ||= Enrollment.find_by(id: log.whodunnit)
        end
      end
    end
  end
end