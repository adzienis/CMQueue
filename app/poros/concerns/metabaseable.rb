module Metabaseable
  private

  def metabase
    @metabase ||= Analytics::Metabase::API::Service.instance
  end

  def mb
    @mb ||= metabase
  end

  def root_collection
    @root_collection ||= metabase.collections.find { |v| v.name == course.name }
  end

  def db
    @db ||= metabase.root_db
  end
end
