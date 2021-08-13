# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
5.times do |v|
  @course0 = Course.create! name: "Course ##{v}",
                            open: true,
                            ta_code: SecureRandom.urlsafe_base64(6),
                            instructor_code: SecureRandom.urlsafe_base64(6),
                            student_code: SecureRandom.urlsafe_base64(6)
end

10.times do |v|
  user = User.create(
    given_name: "arthur ##{v}",
    family_name: "family ##{v}",
    email: "arthur_#{v}@gmail.com",
  )
end

Course.all.each do |course|

  5.times do |v|
    tag = course.tags.create! course_id: course.id,
                              name: "Tag ##{5*course.id + v}",
                              description: SecureRandom.urlsafe_base64(30),
                              archived: false
  end

  User.all.each do |user|
    user.add_role :student, course
    Question.create!(
      description: "I have a problem with my code: #{SecureRandom.urlsafe_base64(30)}",
      location: "https://cmu.zoom.us/j/92548869700?pwd=ODVXWjRCQzFPUlZGbVBqTWFiVGpBZz09",
      tried: "I tried to debug using GDB, but I have been having problems with it.",
      enrollment_id: user.enrollments.most_recent_enrollment_by_course(course.id).id,
      course_id: course.id,
      tags: [course.tags.first]
    )
  end
end
