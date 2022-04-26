# frozen_string_literal: true

ActiveRecord::Base.transaction do
  5.times do |v|
    Course.create! name: "Course ##{v}",
                   open: true,
                   ta_code: SecureRandom.urlsafe_base64(6),
                   instructor_code: SecureRandom.urlsafe_base64(6),
                   student_code: SecureRandom.urlsafe_base64(6)
  end

  Course.all.each do |course|
    instructor = User.create!(
      given_name: "arthur instructor: #{course.name}",
      family_name: "family",
      email: "arthur_#{course.name}_instructor@gmail.com"
    )

    ta = User.create!(
      given_name: "arthur ta: #{course.name}",
      family_name: "family",
      email: "arthur_#{course.name}_ta@gmail.com"
    )

    instructor.add_role(:instructor, course)
    ta.add_role(:ta, course)

    students = Array.new(5).map do |v|
      User.create!(
        given_name: "arthur ##{v}",
        family_name: "family ##{v}",
        email: "arthur_#{v}#{course.name}@gmail.com"
      )
    end

    5.times do |v|
      course.tags.create! course_id: course.id,
                          name: "Tag ##{5 * course.id + v}",
                          description: SecureRandom.urlsafe_base64(30),
                          archived: false
    end

    students.each do |student|
      student.add_role(:student, course)
      Question.create!(
        description: "I have a problem with my code: #{SecureRandom.urlsafe_base64(30)}",
        location: "https://cmu.zoom.us/j/92548869700?pwd=ODVXWjRCQzFPUlZGbVBqTWFiVGpBZz09",
        tried: "I tried to debug using GDB, but I have been having problems with it.",
        enrollment_id: student.enrollment_in_course(course).id,
        tags: [course.tags.first]
      )
    end
  end
end