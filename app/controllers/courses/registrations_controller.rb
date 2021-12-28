class Courses::RegistrationsController < ApplicationController
  def new
    @registration = Forms::Courses::Registration.new
  end

  def create
    @registration = Forms::Courses::Registration.new(**registration_params)
    unless @registration.save
      return redirect_to new_courses_registration_path
    end
    flash[:info] = "Successfully registered new course."
    redirect_to current_user_enrollments_path
  end

  def update
    @registration = Courses::Registration.find(params[:registration_id])
    @registration.update!(registration_params)
  end

  private

  def registration_params
    params.require(:courses_registration).permit(:name, :instructor_id, :approved)
  end
end
