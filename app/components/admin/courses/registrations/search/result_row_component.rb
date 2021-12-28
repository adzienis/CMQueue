module Admin
  module Courses
    module Registrations
      module Search
        class ResultRowComponent < ViewComponent::Base
          def initialize(registration:)
            super
            @registration = registration
          end

          def approval_class
            registration.approved? ? "bg-success" : "bg-danger"
          end

          def approval_msg
            registration.approved? ? "Approved" : "Unapproved"
          end

          private

          attr_reader :registration
        end
      end
    end
  end
end
