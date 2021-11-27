module Charts
  class StaffLogComponent < ViewComponent::Base
    def initialize(course:, options:)
      super
      @course = course
      @options = options
    end

    def title
      "Activity"
    end

    def round_nearest(raw, value)
      (raw/value).floor * value
    end

    def min_value
      if data.present?
        data_min = (data.min{|a,b| a[0] <=> b[0]}[0])
        return round_nearest(data_min, 60*60*1000)
      end

      date.beginning_of_day.to_time.to_i * 1000
    end

    def max_value
      return (date.to_i * 1000 / hour) * hour + hour if date.today?
      (date.end_of_day.to_time.to_i * 1000 / thirty_min) * thirty_min + thirty_min
    end

    def hour
      1000 * 60 * 60
    end

    def thirty_min
      1000 * 60 * 20
    end

    def color_map(state)
      case state
      when 0
        "#777777"
      when 2
        "#00ff00"
      when 3
        "#0000ff"
      when 4
        "#ff0000"
      else
        "#000000"
      end
    end

    def label_map(state)
      case state
      when 0
        "unresolved"
      when 2
        "resolved"
      when 3
        "frozen"
      when 4
        "kicked"
      end
    end

    def labels
      @label ||= raw_data.map{|v| label_map(v[0])}
    end

    def data_color
      @data_color ||= raw_data.map{|v| color_map(v[0])}
    end

    def data
      @data ||= raw_data.map{|v| [v[1], v[2]]}
    end

    def date_range
      @date_range ||= date.all_day
    end

    def date
      @date ||= options[:date].present? ? options[:date] : DateTime.current
    end

    def raw_data
      @raw_data ||= ActiveRecord::Base.connection.exec_query(course.staff.select("question_states.state", "extract(epoch from question_states.created_at)*1000 t", "users.given_name")
                                                                   .joins(:question_states, :user)
                                                                   .group("users.given_name", "question_states.created_at", "question_states.state")
                                                                   .where("question_states.created_at": date_range,
                                                                          "question_states.state": [0,2,3,4]).limit(10).to_sql).rows
    end

    private

    attr_reader :course, :options
  end
end
