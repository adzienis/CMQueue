class Courses::AnalyticsController < ApplicationController
  def index
    @course = Course.find(params[:id])


  end

  def today
    @course = Course.find(params[:id])
    @question_times = User.all.with_role(:ta, :any)
                          .map { |s| s.question_states.where(state: "resolved")
                                      .left_joins(:question)
                                      .where("questions.created_at >= ?", DateTime.now.beginning_of_day)
                                      .select("(question_states.created_at - questions.created_at) as time_to_answer") }
    @avg_time = @question_times.map { |b| b.map { |q| q.time_to_answer }.sum / b.length }.sum / @question_times.length

    @active_tas = User.active_tas_by_date(["resolved"], Time.now, :any)

    @avg_time_per_user = @active_tas.select("users.*, (select avg(question_states.created_at - foo.created_at)
                                                 as avg_time_spent_answering from question_states inner join
                                                (select * from question_states where state = 1) as foo on foo.question_id =
                                                   question_states.question_id where question_states.state = 2)")
  end

  def tas
    @course = Course.find(params[:id])
  end
end
