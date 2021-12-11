class Analytics::Metabase::API::Dashboard
  extend ActiveModel::Naming
  include Metabaseable

  def initialize(dashboard:)
    @dashboard_id = dashboard["id"]
  end

  def to_key
    [id]
  end

  def id
    dashboard["id"]
  end

  def description
    dashboard["description"]
  end

  def name
    dashboard["name"]
  end

  def enable_embedding
    dashboard["enable_embedding"]
  end

  def dashboard
    @dashboard ||= metabase.get_dashboard(dashboard_id: dashboard_id)
  end

  def archive
    Analytics::Metabase::Dashboards::ArchiveDashboard.new(dashboard_id: id, metabase: metabase).call
  end

  def unarchive
    Analytics::Metabase::Dashboards::UnarchiveDashboard.new(dashboard_id: id, metabase: metabase).call
  end

  private

  attr_reader :dashboard_id
end
