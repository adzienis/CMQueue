# frozen_string_literal: true

module Searches
  class QuestionSearch
    def self.get_filtered(params = {
      date_start: Date.today.strftime,
      date_end: Date.today.strftime,
      option: 'given_name',
      search: ''
    })

      filtered_questions = Question.all
                                   .where('questions.created_at >= ?', DateTime.parse(params[:date_start]).beginning_of_day.strftime)
                                   .where('questions.created_at <= ?', DateTime.parse(params[:date_end]).end_of_day.strftime)

      if params[:search].empty?
      else
        filtered_questions = case params[:option]
                             when 'description'
                               filtered_questions
                             .where("LOWER(questions.#{params[:option]}) LIKE LOWER(?)", "#{params[:search]}%")
                             when 'given_name'
                               filtered_questions.joins(:user).where("LOWER(users.#{params[:option]}) LIKE LOWER(?)",
                                                                     "#{params[:search]}%")
                             else
                               filtered_questions
                             end
      end

      filtered_questions
    end
  end
end
