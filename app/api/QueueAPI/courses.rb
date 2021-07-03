# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
module QueueAPI
  class Courses < BaseAPI
    helpers Doorkeeper::Grape::Helpers

    resource :courses do
      desc 'Answer the topmost question in the course.'
      post ':course_id/answer', scopes: [:write] do
        top_question = Question
                         .undiscarded
                         .with_course(Course.find(params[:course_id]))
                         .questions_by_state(['unresolved'])
                         .order(created_at: :desc)
                         .first

        top_question.question_states.create(state: params[:answer][:state],
                                            enrollment_id: params[:answer][:enrollment_id])
        top_question
      end

      desc 'Search for courses by name.'
      params do
        optional :name, type: String
      end
      get 'search', scopes: [:public] do
        courses = Course.all
        courses = courses.where('name LIKE :name', name: "%#{params[:name]}%") if params[:name]

        courses
      end

      desc 'Get all courses'
      get scopes: [:public] do
        Course.all.select(Course.column_names - %w[instructor_code ta_code])
      end

      desc 'Gets the open status of a course'
      params do
        requires :course_id, type: Integer
      end
      get ':course_id/open_status', scopes: [:public] do
        Course.find(params[:course_id]).open
      end

      desc 'Update the open status of a course/'
      params do
        requires :course_id, type: Integer
        requires :status, type: Boolean
      end
      post ':course_id/open', scopes: [:write] do
        course = Course.find(params[:course_id])

        if !doorkeeper_token && current_user.has_any_role?({ name: :ta, resource: course },
                                                           { name: :instructor, resource: course })
          Course.find(params[:course_id]).update(open: params[:status])
        end
      end

      desc 'Get TA\'s with any activity in the past 15 minutes'
      params do
        requires :course_id, type: Integer
      end
      get ':course_id/activeTAs', scopes: [:public] do
        course = Course.find(params[:course_id])
        tas = User.with_course(course).with_any_roles :ta, :instructor
        tas = tas.joins(:enrollments, enrollments: :question_state).where('question_states.created_at > ?',
                                                                          15.minutes.ago).distinct
      end

      get ':course_id/topQuestion', scopes: [:public] do
        question_state = User.find(params[:user_id]).question_state
        top_question = Question.joins(:question_state).where("question_states.id": question_state&.id).undiscarded.first

        top_question.as_json include: %i[user question_state tags] if question_state&.state == 'resolving'
      end
    end
  end
end
