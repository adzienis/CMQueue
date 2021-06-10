class API < Grape::API
  prefix 'api'
  format :json
  mount QueueAPI::UserAPI
  mount QueueAPI::CourseAPI
  mount QueueAPI::QuestionAPI
  mount QueueAPI::TagAPI
  mount QueueAPI::EnrollmentAPI

  add_swagger_documentation \
  info: {
    title: "CMQueue",
    description: "Endpoints available to query information",
    contact_name: "Arthur Dzieniszewski",
    contact_email: "arthurdzieniszewski@gmail.com",
  }
end