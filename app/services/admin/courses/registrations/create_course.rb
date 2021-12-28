module Admin
  module Courses
    module Registrations
      class CreateCourse
        def initialize(registraton)
          @registration = registraton
        end

        def call
          ActiveRecord::Base.transaction do
            @registration.update!(approved: true)
            course = Course.create!(name: registration.name)
            registration.instructor.add_role :instructor, course
          end
        end

        private

        attr_reader :registration
      end
    end
  end
end
