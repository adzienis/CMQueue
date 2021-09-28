module ScopeableByCourseRoles

  def staff_of?(obj)
    ta_of?(obj) || lead_ta_of?(obj) || instructor_of?(obj)
  end

  def privileged_staff_of?(obj)
    lead_ta_of?(obj) || instructor_of?(obj)
  end

  [:ta, :lead_ta, :instructor, :student].each do |role|
    self.define_method("#{role}_of?") do |obj|
      if obj.instance_of? Course
        has_any_role?({ name: role.to_sym, resource: obj })
      elsif  obj.instance_of? Integer
        course = Course.find(obj)
        has_any_role?({ name: role.to_sym, resource: course })
      else
        false
      end
    end
  end

end