module Postgres
  module Views
    def self.create_views_schema(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        CREATE SCHEMA IF NOT EXISTS course_#{course_id}
      SQL
      )

      self.create_user(course_id)
      self.grant_privileges(course_id)
    end

    def self.create_user(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        do $$ begin
          if exists (SELECT usename FROM pg_user WHERE usename = 'course_#{course_id}_user') then
            REVOKE ALL ON SCHEMA course_#{course_id} FROM course_#{course_id}_user;
            REVOKE ALL ON ALL TABLES IN SCHEMA course_#{course_id} FROM course_#{course_id}_user;
          end if;
        end $$;
        DROP ROLE IF EXISTS course_#{course_id}_user;
        CREATE USER course_#{course_id}_user;
        ALTER USER course_#{course_id}_user PASSWORD '#{SecureRandom.urlsafe_base64(10)}';
      SQL
      )
    end

    def self.destroy_user(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        do $$ begin
          if exists (SELECT usename FROM pg_user WHERE usename = 'course_#{course_id}_user') then
            REVOKE ALL ON SCHEMA course_#{course_id} FROM course_#{course_id}_user;
            REVOKE ALL ON ALL TABLES IN SCHEMA course_#{course_id} FROM course_#{course_id}_user;
          end if;
        end $$;
        DROP ROLE IF EXISTS course_#{course_id}_user;
      SQL
      )
    end

    def self.grant_privileges(course_id)
      ActiveRecord::Base.connection.execute(
        <<-SQL
        GRANT ALL ON SCHEMA course_#{course_id} TO GROUP course_#{course_id}_user;
        GRANT SELECT ON ALL TABLES IN SCHEMA course_#{course_id} to course_#{course_id}_user
      SQL
      )
    end
  end
end