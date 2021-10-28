class Postgres::Cleanup::UpdateEnrollmetnForQuestionStates

  #
  # Updates all questions states to have their enrollment for a user updated to the users
  # most recent enrollment.
  #
  def call
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(
        <<-SQL
          with max_ids as (select max(subquery.id) enrollment_id, users.id user_id from users 
          join lateral (select max(id) id from enrollments where enrollments.user_id = users.id) subquery
          ON true group by users.id) update question_states set enrollment_id = max_ids.enrollment_id from enrollments, max_ids
          where enrollments.id = question_states.enrollment_id and enrollments.user_id = max_ids.user_id
        SQL
      )
    end
  end

end