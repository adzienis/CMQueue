class QuestionsController < ApplicationController
  def index

    @questions = Question.all.joins(:user, :question_state, :tags)
    @questions = @questions.where(course_id: params[:course_id]) if params[:course_id]
    @questions = @questions.where(user_id: params[:user_id]) if params[:user_id]
    @questions = @questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

    if params[:cursor]
      @questions = @questions.where('questions.id >= ?', params[:cursor]).limit(5)
      @offset = @questions.where('questions.id >= ?', params[:cursor]).offset(5).first

      respond_to do |format|
        format.html
        format.json do
          render json: {
            data: @questions,
            cursor: @offset
          }, include: [:user, :question_state, :tags]
        end
      end

      return
    end

    respond_to do |format|
      format.html
      format.json { render json: @questions, include: [:user, :question_state, :tags] }
    end
  end

  def show
    @question = Question.find(params[:id])
    @previous_questions = Question.previous_questions(@question).order("question_states.created_at DESC")
  end

  def create
    @question = Question.create(question_params)
    @question.tags = Tag.find(params[:question][:tags])

    if @question.errors.any?

      render json: @question.errors.messages.to_json, status: :unprocessable_entity
      return
    end

    redirect_to course_path(@question.course)
  end

  def update
    @question = Question.find(params[:id])
    @question.update(question_params)
    @question.tags = (Tag.find(params[:question][:tags]))

    respond_to do |format|
      format.html
      format.json { render json: @question }
    end
  end

  def paginated_previous_questions
    @question = Question.find(params[:id])
    @paginated_past_questions = Question
                                  .left_joins(:question_state)
                                  .where("question_states.state = #{QuestionState.states["resolved"]}")
                                  .where("questions.created_at < ?", @question.created_at)
                                  .where(user_id: @question.user_id)
                                  .where(course_id: @question.course_id)
                                  .order("question_states.created_at DESC")
                                  .limit(5)
    respond_to do |format|
      format.html
      format.json { render json: @paginated_past_questions, include: :question_state }
    end
  end

  def destroy
    Question.find(params[:id]).destroy
  end

  private

  def question_params
    params.require(:question).permit(:course_id, :description, :tried, :location, :user_id)
  end
end
