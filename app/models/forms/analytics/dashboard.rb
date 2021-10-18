class Forms::Analytics::Dashboard
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor(:dashboard, :dashboard_params)

  delegate :id, to: :dashboard, allow_nil: true

  attribute :name, :string
  attribute :course_id, :integer
  attribute :dashboard_type, :string
  attribute :url, :string
  attribute :metabase_id, :integer

  validates :name, :course_id, :dashboard_type, :metabase_id, presence: true

  # Defined in ActiveRecord::Persistence, we need to define this so
  # simple form knows whether to create or update
  def persisted?
    dashboard.present?
  end

  def course
    return @course if defined?(@course)

    @course = dashboard ? dashboard.course : Course.find(course_id)
  end

  def initialize(*)
    super
    if dashboard
      self.name ||= dashboard.data["name"]
      self.dashboard_type ||= dashboard.data["dashboard_type"]
      self.url ||= dashboard.data["url"]
      self.metabase_id ||= dashboard.data["metabase_id"]
      self.course_id ||= dashboard.course_id
    end

  end

  def promote_errors(child)
    child.errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end

  def dashboard_params_adapter
    {
      course_id: course_id,
      data: {
        name: name,
        dashboard_type: dashboard_type,
        url: url,
        metabase_id: metabase_id
      }
    }
  end

  def save
    begin
      ActiveRecord::Base.transaction do
        raise Exception.new("invalid") unless valid?

        if dashboard
          dashboard.assign_attributes(dashboard_params_adapter)
        else
          self.dashboard = Analytics::Dashboard.new(
            course_id: course_id,
            data: {
              name: name,
              dashboard_type: dashboard_type,
              url: url,
              metabase_id: metabase_id
            })
        end

        dashboard.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      promote_errors(e.record) and return false
    rescue Exception => e
      return false
    ensure
      true
    end

    #course, role = Course.find_by_code(@code)

    #@enrollment = @current_user.enrollments.build(role: course.roles.find_or_create_by(name: role))

    #@enrollment.save

    #promote_errors(@enrollment)
  end

end
