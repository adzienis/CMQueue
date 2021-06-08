Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :tags
  resources :question_states
  resources :messages

  get 'courses/search', to: "courses#search"

  resources :questions, shallow: true do
    resources :messages
    member do
      get 'paginatedPreviousQuestions', to: "questions#paginated_previous_questions"
      get 'previousQuestions', to: "questions#previous_questions"
    end
  end

  resources :courses, only: [] do
    resources :questions
    resources :tags
    resources :users
    resources :question_states
    resources :messages
  end
  resources :questions
  resources :courses, param: :course_id do
    member do
      get 'roster', to: "courses#roster"
      get 'courseInfo', to: "courses#course_info"
      get 'settings/queues', to: "courses#queues"
      get 'activeTAs', to: "courses#active_tas"
      get 'analytics', to: "courses/analytics#index"
      get 'analytics/today', to: "courses/analytics#today"
      get 'analytics/tas', to: "courses/analytics#tas"
      get 'settings/course', to: "courses/settings#index"
      post 'answer', to: "courses#answer"
      get 'answer', to: "courses#answer_page"
      get 'answer/question', to: "courses#answer_page", as: :answer_question
      get 'answer/previousQuestions', to: "courses#answer_page"
      post 'putBack', to: "courses#putBack"
      post 'finishAnswering', to: "courses#finishAnswering"
      post 'freeze', to: "courses#freeze"
      post 'kick', to: "courses#kick"
      get 'topQuestion', to: "courses#top_question"
      get 'open', to: "courses#open_status"
      post 'open', to: "courses#open"
    end
  end

  resources :users, shallow: true do
    resources :questions
  end
  resource :user, shallow: true do
    resources :enrollments, controller: 'users/enrollments'
  end

  get 'landing/', to: "landing#index"
  root to: "landing#index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', to: 'landing#index', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
end
