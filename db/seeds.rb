# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

course = Course.create! name: "course#{0}",
                       ta_code: SecureRandom.urlsafe_base64(6),
                       instructor_code: SecureRandom.urlsafe_base64(6),
                       student_code: SecureRandom.urlsafe_base64(6)

10.times do |v|


  tag = course.tags.create!(id: v, course_id: course.id,
                            name: SecureRandom.urlsafe_base64(10),
                            description: SecureRandom.urlsafe_base64(30))

  user = User.create!(given_name: "arthur#{v}")
  user.courses << course
  user.questions.create!(course_id: course.id,
                  location: SecureRandom.urlsafe_base64(6),
                  tried: SecureRandom.urlsafe_base64(6),
                  description: SecureRandom.urlsafe_base64(6))


end
