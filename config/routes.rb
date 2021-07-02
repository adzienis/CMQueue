# frozen_string_literal: true

Rails.application.routes.draw do
  get 'roles/index'
  get 'roles/create'
  get 'roles/show'
  get 'authentications/create'
  get 'oauth_accounts/create_or_update'
  get 'oauth_accounts/error'

  get '/swagger', to: 'application#swagger'

  get 'courses/search', to: 'courses#search'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount PgHero::Engine, at: 'pghero'
  mount API => '/'

  resources :tags do
    collection do
      get 'download_form', to: "tags#download_form"
    end
  end
  resources :question_states
  resources :messages
  resources :applications
  resources :semesters
  resources :settings
  resources :enrollments do
    collection do
      get 'download_form', to: "enrollments#download_form"
    end
  end
  resources :roles
  resources :questions do
    member do
      get 'paginatedPreviousQuestions', to: 'questions#paginated_previous_questions'
      get 'previousQuestions', to: 'questions#previous_questions'
    end

    collection do
      get 'download_form', to: "questions#download_form"
    end
  end
  resources :courses, param: :course_id

  resources :questions, shallow: true do
    resources :messages
  end

  resources :users do
    resource :settings do
      get 'notifications', to: "settings#notifications"
    end
  end

  resources :users, only: [], shallow: true do
    resources :questions
    resources :tags
  end

  resources :courses do
    resources :questions do
      collection do
        get 'count', to: 'questions#count'
      end
    end
    resources :tags
    resources :users, param: :user_id
    resources :question_states
    resources :messages
    resources :enrollments
    resources :applications
    resources :semesters
    resources :roles
  end

  resources :courses, only: [], param: :course_id do
    member do
      use_doorkeeper do
        controllers applications: "oauth/applications"
      end
    end
  end

  resources :courses, param: :course_id do
    member do
      get 'roster', to: 'courses#roster'
      get 'courseInfo', to: 'courses#course_info'
      get 'settings/queues', to: 'courses#queues'
      get 'activeTAs', to: 'courses#active_tas'
      get 'analytics', to: 'courses/analytics#index'
      get 'analytics/today', to: 'courses/analytics#today'
      get 'analytics/tas', to: 'courses/analytics#tas'
      get 'settings/course', to: 'courses/settings#index'
      post 'answer', to: 'courses#answer'
      get 'answer', to: 'courses#answer_page'
      get 'answer/question', to: 'courses#answer_page', as: :answer_question
      get 'answer/previousQuestions', to: 'courses#answer_page'
      post 'putBack', to: 'courses#putBack'
      post 'finishAnswering', to: 'courses#finishAnswering'
      post 'freeze', to: 'courses#freeze'
      post 'kick', to: 'courses#kick'
      get 'topQuestion', to: 'courses#top_question'
      get 'open', to: 'courses#open_status'
      post 'open', to: 'courses#open'
    end
  end
  resource :user, shallow: true do
    resources :enrollments, controller: 'users/enrollments'
  end

  get 'landing/', to: 'landing#index'

  get '/users/auth/google_oauth2/callback', to: 'oauth_accounts#create_or_update', constraints: lambda { |req|
    req.env['omniauth.origin'] !~ /login/
  }
  get '/users/auth/failure', to: 'oauth_accounts#error', constraints: lambda { |req|
    req.env['omniauth.origin'] !~ /login/
  }

  root to: 'landing#index'

  devise_scope :user do
    get 'auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2'
    get 'auth/failure', to: 'users/omniauth_callbacks#failure'
    get 'sign_in', to: 'landing#index', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # devise_for :users, skip: :all
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
