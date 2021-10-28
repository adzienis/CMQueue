# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  load_and_authorize_resource id_param: :enrollment_id, except: :create

  respond_to :html, :json

  def index

    @enrollments = @enrollments
                     .undiscarded
                     .joins(:user, :role, :course)
                     .order("enrollments.created_at": :desc)
    @enrollments = @enrollments.where(user_id: params[:user_id]) if params[:user_id]
    @enrollments = @enrollments
                     .joins(:role)
                     .where("roles.resource_id": params[:course_id]) if params[:course_id]
    @enrollments = @enrollments.with_course_roles(JSON.parse(params[:role])) if params[:role]

    @enrollments_ransack = @enrollments.ransack(params[:q])

    @pagy, @records = pagy @enrollments_ransack.result

    respond_to do |format|
      format.html
      format.json { render json: @enrollments, include: [:role, :course] }
      format.js { render inline: "window.open('#{URI::HTTP.build(path: "#{request.path}.csv", query: request.query_parameters.to_query, format: :csv)}', '_blank')" }
      format.csv {
        send_data Enrollment.to_csv(params[:enrollment].to_unsafe_h, @enrollments_ransack.result),
                  filename: helpers.csv_download_name(controller_name.classify.constantize)
      }
    end
  end

  def import
    begin
      file = params[:csv_file].read
      json = JSON.parse(file)

      json.each do |student|
        email = student["email"]
        name = student["name"]

        enrollment = student["enrollments"][0]
        type = enrollment["type"]

        split_name = name.split(" ")
        given_name = split_name[-1]
        family_name = split_name[0]

        # create a new user if they don't already exist

        user = User.find_by(email: email)
        user = User.find_or_create_by(email: email, given_name: given_name, family_name: family_name) unless user

        return if user == current_user

        # remove the existing enrollment
        user.enrollments.with_courses(@course.id).discard_all

        case type
        when "StudentEnrollment"
          user.add_role :student, @course
        when "TaEnrollment"
          user.add_role :ta, @course
        when "TeacherEnrollment"
          user.add_role :instructor, @course
        end
      end

      SiteNotification.success(current_user, "Successfully imported file.", 2)
    rescue => e
      SiteNotification.failure(current_user, "Failed to import file.")
    end

    redirect_to search_course_enrollments_path(@course)
  end

  def download_form
  end

  def edit
  end

  def update
    @enrollment.update(enrollment_params)

    respond_with @enrollment, location: search_course_enrollments_path(@course)
  end

  def show
  end

  def new
  end

  def create
    @enrollment = Enrollment.new(enrollment_params)

    if @enrollment.valid?
      authorize! :create, @enrollment
      @enrollment.save
    end

    respond_with @enrollment, location: search_course_enrollments_path(@course)
  end

  def destroy
    @enrollment.discard

    respond_with @enrollment, location: search_course_enrollments_path(@course)
  end

  private

  def enrollment_params
    params.require(:enrollment).permit(:user_id, :role_id, :semester)
  end
end
