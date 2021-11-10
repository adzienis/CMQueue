class Postgres::UpdateEnrollmentForQuestions

  #
  # Updates all questions to have their enrollment for a user updated to the users
  # most recent enrollment.
  #
  def call
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(
        <<-SQL
          with max_ids as (select max(subquery.id) enrollment_id, users.id user_id from users 
          join lateral (select max(id) id from enrollments where enrollments.user_id = users.id) subquery 
          ON true group by users.id) update questions set enrollment_id = foo.enrollment_id from enrollments, max_ids
          where enrollments.id = questions.enrollment_id and enrollments.user_id = max_ids.user_id
        SQL
      )
    end
  end

end