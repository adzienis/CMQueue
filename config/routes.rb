Rails.application.routes.draw do


  get 'admin/index'
  get 'admin/show'
  get 'admin/settings'
  resources :tags
  resources :question_states
  resources :messages

  get 'courses/search', to: "courses#search"

  resources :courses do
    member do
      get 'roster', to: "courses#roster"
      get 'courseInfo', to: "courses#course_info"
      get 'settings/queues', to: "courses#queues"
      get 'activeTAs', to: "courses#active_tas"
      get 'analytics', to: "courses/analytics#index"
      get 'settings/course', to: "courses/settings#index"
      post 'answer', to: "courses#answer"
      get 'answer', to: "courses#answer_page"
      post 'putBack', to: "courses#putBack"
      post 'finishAnswering', to: "courses#finishAnswering"
      post 'freeze', to: "courses#freeze"
      post 'kick', to: "courses#kick"
      get 'topQuestion', to: "courses#top_question"
      get 'open', to: "courses#open_status"
      post 'open', to: "courses#open"
    end
  end

  resources :questions, shallow: true do
    resources :messages
    member do
      get 'paginatedPreviousQuestions', to: "questions#paginated_previous_questions"
    end
  end

  resources :courses, shallow: true do
    resources :questions
    resources :tags
  end
  resources :questions
  resources :courses

  resources :users

  resource :users, shallow: true do
    resources :courses, controller: 'users/courses'
    resources :enrollments, controller: 'users/enrollments'
  end

  resource :user, shallow: true do
    resources :courses, controller: 'users/courses'
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
