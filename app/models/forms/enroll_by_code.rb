class Forms::EnrollByCode
  include ActiveModel::Model

  attr_accessor(
    :code,
    :current_user
  )

  validate :course_exists

  def promote_errors(child)
    child.errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def course_exists
    if @code
      errors.add(:code, "is invalid") unless Course.find_by_code?(@code)
    end
  end

  def initialize(code, current_user)
    @code = code
    @current_user = current_user
  end

  def save
    return false unless valid?

    course, role = Course.find_by_code(@code)

    @enrollment = @current_user.enrollments.build(role: course.roles.find_or_create_by(name: role))

    @enrollment.save

    promote_errors(@enrollment)
  end

end
