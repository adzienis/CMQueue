class AddTagGroupToTags < ActiveRecord::Migration[6.1]
  def up
    add_reference :tags, :tag_group, index: true, foreign_key: true
  end

  def down
    remove_reference :tags, :tag_group
  end
end
