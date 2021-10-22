class Courses::QueuedQuestionsController < ApplicationController
  def index
    @pagy, @records = pagy(@course.questions_on_queue)
  end
end
