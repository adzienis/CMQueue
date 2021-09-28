require './lib/postgres/views.rb'

class RemoveTagGroupIdFromTags < ActiveRecord::Migration[6.1]
  def up

    Postgres::Views::destroy_all_course_views
    remove_reference :tags, :tag_group
  end

  def down
    add_reference :tags, :tag_group
  end
end
