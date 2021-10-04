class Forms::QuestionController < ApplicationController

  respond_to :html, :json

  def create

    @available_tags = @course.available_tags

    merged_question_params = question_params.to_h.symbolize_keys.merge(tag_ids: params[:tag_groups].values.reduce { |x, y| x + y })
    @question_form = Forms::Question.new(current_user: current_user,
                                         question_params: merged_question_params)

    @question_form.save

    respond_with @question_form, location: edit_course_forms_question_path(@course)
  end

  def update
    @question = current_user.active_question
    @available_tags = @course.available_tags

    merged_question_params = question_params.to_h.symbolize_keys.merge(tag_ids: params[:tag_groups].values.reduce { |x, y| x + y })

    @question_form = Forms::Question.new(current_user: current_user, question: @question, question_params: merged_question_params)

    @question_form.save

    respond_with @question_form, location: edit_course_forms_question_path(@course)
  end

  def new
    redirect_to edit_course_forms_question_path(current_user.active_question.course) if current_user.active_question?(@course)
    @available_tags = @course.available_tags
    @enrollment = current_user.enrollment_in_course(@course)

    @question_form = Forms::Question.new(question: Question.new(enrollment: @enrollment))
  end

  def edit
    @question = current_user.active_question(course: @course)
    redirect_to new_course_forms_question_path(@course) and return if @question.nil?


    @enrollment = current_user.enrollment_in_course(@course)

    @question_form = Forms::Question.new(question: @question)

    @available_tags = @course.available_tags
  end

  def show
    @question = @questions.find(params[:question_id])
  end

  def destroy
    current_user.active_question.active_question(course: @course).discard

    redirect_to new_course_forms_question_path(@course)
  end

  private

  def question_params
    params.require(:question).permit(:description, :tried, :location, :enrollment_id, :course_id, tag_ids: [])
  end
end
