class ChangeSettingValueToBag < ActiveRecord::Migration[6.1]
  def up
    remove_column :settings, :value
    add_column :settings, :bag, :jsonb, default: {}

    User.all.each do |user|
      user.settings.destroy_all
      user.settings.create([{
        bag: {
          key: "notifications",
          label: "Notifications",
          value: "false",
          description: "Allow notifications.",
          type: "boolean",
          category: "Notifications"
        }
      }])
    end

    Course.all.each do |course|
      course.settings.destroy_all
      course.settings.create([{
        bag: {
          label: "Searchable",
          key: "searchable",
          value: "false",
          description: "Allow students to search for this course.",
          type: "boolean",
          category: "General"
        }
      }, {
        bag: {
          label: "Allow Enrollment",
          key: "allow_enrollment",
          value: "false",
          description: "Allow users to enroll in the course.",
          type: "boolean",
          category: "Enrollment"
        }
      }])
    end
  end

  def down
    remove_column :settings, :bag
    add_column :settings, :value, :jsonb, default: {}
  end
end
