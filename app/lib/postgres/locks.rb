module Postgres
  class Locks
    def self.pg_try_advisory_xact_lock(id)
      ActiveRecord::Base.connection.exec_query("SELECT pg_try_advisory_xact_lock(#{id})").rows[0][0]
    end

    def self.pg_advisory_xact_lock(id)
      ActiveRecord::Base.connection.exec_query("SELECT pg_advisory_xact_lock(#{id})").rows[0][0]
    end
  end
end
