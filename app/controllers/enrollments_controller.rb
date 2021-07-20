# frozen_string_literal: true

class EnrollmentsController < ApplicationController
  load_and_authorize_resource

  def index
    @course = Course.find(params[:course_id]) if params[:course_id]

    @enrollments_ransack = Enrollment
                             .undiscarded
                             .joins(:user, :role)
                             .includes(:user, :role)
                             .order("enrollments.created_at": :desc)
    @enrollments_ransack = @enrollments_ransack
                             .joins(:role)
                             .where("roles.resource_id": params[:course_id]) if params[:course_id]
    @enrollments_ransack = @enrollments_ransack.where(user_id: params[:user_id]) if params[:user_id]

    @enrollments_ransack = @enrollments_ransack.ransack(params[:q])

    @pagy, @records = pagy @enrollments_ransack.result.distinct

    respond_to do |format|
      format.html
      format.js { render inline: "window.open('#{URI::HTTP.build(path: "#{request.path}.csv", query: request.query_parameters.to_query, format: :csv)}', '_blank')" }
      format.csv {
        send_data helpers.to_csv(params[:enrollment].to_unsafe_h, @enrollments_ransack.result, Enrollment),
                  filename: helpers.csv_download_name(controller_name.classify.constantize)
      }
    end
  end

  def import
    course = Course.find(params[:course_id])
    CSV.foreach(params[:csv_file], headers: true) do |row|
      user = User.find_or_create_by(row.to_hash)
      user.add_role :student, course if user
    end

    SiteNotification.with(type: "Success", body: "Successfully imported file.", title: "Success", delay: 2).deliver(current_user)

    redirect_to request.referer
  end

  def download_form

  end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
    @enrollment = Enrollment.find(params[:id])
  end

  def new
    @course = Course.find(params[:course_id]) if params[:course_id]
    @enrollment = Enrollment.new
  end

  def create
    @course = Course.find_by(id: params[:course_id]) if params[:course_id]
    @enrollment = Enrollment.create(enrollment_params)

    if @course
      redirect_to course_enrollments_path(@course) unless @enrollment.errors.count > 0
    else
      redirect_to enrollments_path unless @enrollment.errors.count > 0
    end


    render turbo_stream:  (turbo_stream.replace @enrollment,  partial: "shared/new_form", locals: { model_instance: @enrollment, options:{ except: [:question_states, :questions]}}) and return unless @enrollment.errors.count == 0

  end

  def destroy
    @enrollment = Enrollment.find_by(id: params[:id]).discard

    redirect_to request.referer

  end

  private

  def enrollment_params
    params.require(:enrollment).permit(:user_id, :role_id, :semester)
  end
end
