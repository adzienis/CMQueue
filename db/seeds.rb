# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
  5.times do |v|
    @course0 = Course.create! name: "course_#{v}",
                              ta_code: SecureRandom.urlsafe_base64(6),
                              instructor_code: SecureRandom.urlsafe_base64(6),
                              student_code: SecureRandom.urlsafe_base64(6)
  end

  5.times do |v|
    tag = @course0.tags.create! id: v, course_id: @course0.id,
                                name: SecureRandom.urlsafe_base64(10),
                                description: SecureRandom.urlsafe_base64(30)
  end

  20.times do |v|
    user = User.create(
      given_name: "arthur_#{v}",
      family_name: "family_#{v}",
      email: "arthur_#{v}@gmail.com",
    )

    Course.all.each do |course|
      user.add_role :student, course

      Question.create!(
        description: SecureRandom.urlsafe_base64(30),
        location: SecureRandom.urlsafe_base64(30),
        tried: SecureRandom.urlsafe_base64(30),
        enrollment_id: user.enrollments.most_recent_enrollment_by_course(course.id).id,
        course_id: course.id,
        tags: [Tag.find(1)]
      )
    end
  end
