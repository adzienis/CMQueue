class Postgres::Cleanup::CleanupEnrollments

  #
  # Removes all enrollments that aren't the most recent one.s
  #
  def call
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(
        <<-SQL
          WITH max_ids as (select max(subquery.id) enrollment_id, users.id user_id from users 
          join lateral (select max(id) id from enrollments where enrollments.user_id = users.id) subquery 
          ON true group by users.id) delete from enrollments using max_ids 
          where not exists (select * from max_ids where max_ids.enrollment_id = enrollments.id)
        SQL
      )
    end
  end

end