# frozen_string_literal: true

class API < Grape::API
  prefix 'api'
  format :json
  mount QueueAPI::Users
  mount QueueAPI::Courses
  mount QueueAPI::Questions
  mount QueueAPI::Tags
  mount QueueAPI::Enrollments
  mount QueueAPI::Messages
  mount QueueAPI::QuestionStates

  add_swagger_documentation \
    info: {
      title: 'CMQueue',
      description: 'Endpoints available to query information',
      contact_name: 'Arthur Dzieniszewski',
      contact_email: 'arthurdzieniszewski@gmail.com'
    }
end
