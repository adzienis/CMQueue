class Analytics::Metabase::SyncDatabaseJob < ApplicationJob
  include Metabaseable

  queue_as :default

  def perform
    metabase.sync_database(database_id: db.id)
  end
end
