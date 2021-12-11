class Forms::EnrollByCodeController < ApplicationController
  respond_to :html, :json

  rescue_from ActiveRecord::RecordInvalid, with: :validator

  def validator(exception)
    respond_with exception.record
  end

  def new
  end

  def create
    enrollment_creator = Forms::EnrollByCode.new(params[:code], current_user) if params[:code]
    enrollment_creator = Forms::EnrollBySearch.new(params[:course_id], current_user) if params[:course_id]

    enrollment_creator.save

    if enrollment_creator.errors.present?
      respond_with enrollment_creator
    else
      respond_with enrollment_creator.enrollment
    end
  end
end
