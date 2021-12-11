class Analytics::Metabase::API::Database
  include Metabaseable

  def initialize(database:)
    @database = database
  end

  def id
    database["id"]
  end

  def name
    database["name"]
  end

  private

  attr_reader :database
end
