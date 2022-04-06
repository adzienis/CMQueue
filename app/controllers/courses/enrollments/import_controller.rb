module Courses
  module Enrollments
    class ImportController < ApplicationController
      def current_ability
        @current_ability ||= Courses::EnrollmentAbility.new(current_user, {
          params: params,
          path_parameters: request.path_parameters
        })
      end

      def index
        authorize! :import, Enrollment
      end

      def create
        authorize! :import, Enrollment

        begin
          file = params[:file].read
          json = JSON.parse(file)

          new_record = @course.enrollments_import_records.create
          new_record.record.attach(params[:file])

          ImportEnrollmentsJob.perform_later(json: json, course: @course, current_user: current_user, import_record: new_record)
        rescue JSON::ParserError
          flash[:error] = "Failed to import file: failed to parse file (make sure to upload a valid json file)."
          return redirect_to import_course_enrollments_path(@course)
        rescue Exception
          flash[:error] = "Failed to import file."
          return redirect_to import_course_enrollments_path(@course)
        end
        flash[:success] = "Your enrollment import has begun. You will be notified when your import is finished."
        redirect_to search_course_enrollments_path(@course)
      end
    end

  end
end