class System::BackupDatabaseJob < ApplicationJob
  queue_as :default

  def perform
    system("pg_dumpall -d #{ENV["DATABASE_URL"]} -f backup.sql")
  end
end
