# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

case Rails.env
when "development"
  @course0 = Course.create! name: 'course0',
                          ta_code: SecureRandom.urlsafe_base64(6),
                          instructor_code: SecureRandom.urlsafe_base64(6),
                          student_code: SecureRandom.urlsafe_base64(6)

  2.times do |v|
    tag = @course0.tags.create! id: v, course_id: @course0.id,
                              name: SecureRandom.urlsafe_base64(10),
                              description: SecureRandom.urlsafe_base64(30)
  end

  20.times do |v|
    user = User.create(
      given_name: "arthur_#{v}",
      family_name: "family_#{v}",
      email: "arthur_#{v}@gmail.com",
      provider: "google_oauth2",
      uid: SecureRandom.urlsafe_base64(10)
    )

    user.add_role :student, @course0

    Question.create!(
      description: "foo",
      location: "foo",
      tried: "test",
      enrollment_id: user.enrollments.most_recent_enrollment_by_course(@course0.id).id,
      course_id: @course0.id,
      tags: [Tag.find(1)]
      )
  end

when "production"
end
