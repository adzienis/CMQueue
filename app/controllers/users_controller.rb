# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource id_param: :user_id

  def current_ability
    @current_ability ||= ::UserAbility.new(current_user,{
      params: params,
      path_parameters: request.path_parameters
    })
  end

  def index
    @users_ransack = @users.with_courses(params[:course_id]) if params[:course_id]

    @users_ransack = @users_ransack.ransack(params[:q])

    @pagy, @records = pagy @users_ransack.result
  end

  def enrollments; end

  def show
    if @course && @user.has_role?(:ta, @course)
      @questions = QuestionState.left_joins(:user).where("users.id": @user.id).includes(:question).where("question_states.state": 'resolved')
    else
      @questions = QuestionState
                   .joins(:question)
                   .joins('inner join users on users.id = questions.user_id')
                   .where('users.id = ?', @user.id)
                   .where('question_states.id = (select max(question_states.id) from question_states where question_states.question_id = questions.id)')
      @unique_questions = @questions
    end
  end
end
