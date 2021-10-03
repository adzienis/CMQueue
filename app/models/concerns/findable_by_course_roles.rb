module FindableByCourseRoles
  extend ActiveSupport::Concern

  included do
    [:ta, :lead_ta, :instructor, :student].each do |role|
      self.class.define_method("find_#{role}") do |obj|

        if obj.instance_of? Course
          find_by(name: role, resource: obj)
        elsif obj.instance_of? Integer
          find_by(name: role, resource_id: obj, resource_type: "Course")
        else
          nil
        end
      end
    end
  end
end