class Forms::EnrollBySearch
  include ActiveModel::Model

  attr_accessor(
    :course_id,
    :current_user,
    :enrollment
  )

  validates :course_id, presence: true


  def promote_errors(child)
    child.errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def initialize(course_id, current_user)
    @course_id = course_id
    @current_user = current_user
  end

  def save
    return false unless valid?

    @course = Course.find(@course_id)

    @enrollment = @current_user.enrollments.build(role: @course.roles.find_or_create_by(name: "student"))

    @enrollment.save

    promote_errors(@enrollment)
  end

end
