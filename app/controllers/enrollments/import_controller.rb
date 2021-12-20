class Enrollments::ImportController < ApplicationController
  def current_ability
    @current_ability ||= ::EnrollmentAbility.new(current_user, {
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

      ImportEnrollmentsJob.perform_later(json: json, course: @course, current_user: current_user)
    rescue JSON::ParserError
      flash.now[:error] = "Failed to import file: failed to parse file (make sure to upload a valid json file)."
      render(:index, status: 400) and return
    rescue Exception
      flash.now[:error] = "Failed to import file."
      render(:index) and return
    end
    flash[:success] = "Your enrollment import has begun. You will be notified when your import is finished."
    redirect_to search_course_enrollments_path(@course)
  end
end
