class QuestionsController < ApplicationController
  load_and_authorize_resource

  def index
    @course = Course.find(params[:course_id]) if params[:course_id]

    @questions = @questions.includes(:user, :question_state, :tags)
    @questions = @questions.where(course_id: params[:course_id]) if params[:course_id]
    @questions = @questions.where(user_id: params[:user_id]) if params[:user_id]
    @questions = @questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

    if params[:cursor]
      @questions = @questions.order("questions.updated_at DESC").limit(5) if params[:cursor] == "-1"
      @questions = @questions.where('questions.id <= ?', params[:cursor]).order("questions.updated_at DESC").limit(5) unless params[:cursor] == "-1"
      @offset = @questions.offset(5).first

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

    @questions_ransack1 = QuestionState.where(question_id: Question.all.accessible_by(current_ability).pluck(:id))
    @questions_ransack1 = @questions_ransack1.joins(:question).where("questions.course_id": params[:course_id]) if params[:course_id]
    @questions_ransack1 = @questions_ransack1.joins(:question).where("questions.user_id": params[:user_id]) if params[:user_id]

    @questions_ransack1 = @questions_ransack1.left_joins(:question, :user).select("distinct on(questions.id, questions.user_id) question_states.id ")

    @questions_ransack ||= Question.joins(:question_states).where("question_states.id in (#{@questions_ransack1.to_sql})").ransack(params[:q])

    @pagy, @records = pagy @questions_ransack.result

    respond_to do |format|
      format.html
      format.json { render json: @questions, include: [:user, :question_state, :tags] }
    end
  end

  def count
    @course = Course.find(params[:course_id]) if params[:course_id]

    @questions = Question.joins(:user, :question_state, :tags)
    @questions = @questions.where(course_id: params[:course_id]) if params[:course_id]
    @questions = @questions.where(user_id: params[:user_id]) if params[:user_id]
    @questions = @questions.questions_by_state(JSON.parse(params[:state])) if params[:state]

    respond_to do |format|
      format.html
      format.json do
        render json: @questions.count
      end
    end
  end

  def previous_questions
    @question = Question.find(params[:id])
    @previous_questions = Question.previous_questions(@question).order("question_states.created_at DESC")

  end

  def edit
    @question = Question.find(params[:id])
    @course = Course.find(params[:course_id]) if params[:course_id]
  end

  def show
    @course = Course.find(params[:course_id]) if params[:course_id]
    @question = Question.find(params[:id])
    @previous_questions = Question.previous_questions(@question.id)
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
    @question.tags = (Tag.find(params[:question][:tags])) if params.dig(:question, :tags)

    respond_to do |format|
      format.html { redirect_to course_questions_path(@question.course) }
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
    params.require(:question).permit(:course_id, :description, :tried, :location, :user_id, :title)
  end
end
