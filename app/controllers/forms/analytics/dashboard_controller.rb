class Forms::Analytics::Dashboard < ApplicationController
  respond_to :html, :json

  def create
    @dashboard_form = Forms::Analytics::Dashboard

  end

  def update
  end

  def new
  end

  def edit
  end

  def show
  end

  def destroy
  end

  private

  def question_params
    params.require(:question).permit(:description, :tried, :location, :enrollment_id, :course_id, tag_ids: [])
  end
end
