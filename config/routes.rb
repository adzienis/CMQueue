# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :forms do
    get 'question/create'
    get 'question/update'
    get 'question/show'
  end
  post 'enroll', to: "forms/enroll_by_code#create"
  namespace :courses do
    get 'queue/index'
  end
  get "activity", to: "summaries#activity"
  get "answer_time", to: "summaries#answer_time"
  get "grouped_tags", to: "summaries#grouped_tags"

  resources :tag_groups

  namespace :admin do
    namespace :doorkeeper do
      resources :access_grants
      resources :access_tokens
      resources :applications
    end
    resources :users
    resources :roles do
      get :export, on: :collection
    end
    resources :enrollments
    resources :announcements
    resources :question_states
    resources :question_tags
    resource :settings, param: :setting_id
    resources :notifications
    resources :questions
    resources :tags
    resources :courses

    root to: "users#index"
  end

  get '/api/swagger', to: 'application#swagger', as: :swagger
  get '/demo', to: redirect("https://cmqueue-demo.herokuapp.com/"), as: :demo

  #mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount PgHero::Engine, at: 'pghero'
  mount API => '/'

  resource :user, as: :current_user, user_scope: true do
    resources :enrollments, controller: 'users/enrollments'
  end

  resources :tags do
    collection do
      get 'download', to: "tags#download_form"
      post 'import', to: "tags#import"
    end
  end


  namespace :metabase do
    resources :dashboards, param: :dashboard_id
  end

  resources :question_states

  resources :messages

  resources :settings, param: :setting_id

  resources :enrollments do
    collection do
      get 'download', to: "enrollments#download_form"
      post 'import', to: "enrollments#import"
    end
  end

  resources :roles

  resources :questions, shallow: true, only: [] do
    resources :messages
    resources :question_states
  end

  resources :questions, param: :question_id do
    member do
      get 'paginatedPreviousQuestions', to: 'questions#paginated_previous_questions'
      get 'previousQuestions', to: 'questions#previous_questions'
      post 'acknowledge', to: 'questions#acknowledge'
      post 'update_state', to: 'questions#update_state'
    end
    collection do
      get 'download', to: "questions#download_form"
      get 'position', to: 'questions#position'
    end
  end

  resources :courses, param: :course_id

  resources :users, only: [], model_name: "User" do
    resources :questions
    resources :courses, param: :course_id
    resources :enrollments
    resources :tags
    resources :notifications
    resource :settings do
      get 'notifications', to: "settings#notifications"
    end
    member do
      get "topQuestion", to: "courses#top_question"
    end
  end

  resources :users, param: :user_id

  resources :courses, only: [], model_name: "Course" do

    resources :questions, param: :question_id, except: [:new, :create] do
      collection do
        get 'download', to: "questions#download_form"
      end
    end

    resources :tags do
      collection do
        get 'download', to: "tags#download_form"
      end
    end

    namespace :forms do
      resource :question, only: [:new, :create, :edit, :update, :destroy], controller: "question"
    end

    namespace :metabase do
      resources :dashboards, param: :dashboard_id
    end

    resources :tag_groups, param: :tag_group_id

    resources :users, param: :user_id

    resources :question_states

    resources :messages

    resources :settings, param: :setting_id

    resources :certificates do
      collection do
        get 'download', to: "certificates#download"
      end
    end

    resources :enrollments do
      collection do
        get 'download', to: "enrollments#download_form"
      end
    end
    resources :roles

    use_doorkeeper do
      controllers applications: "oauth/applications"
    end
  end

  #use_doorkeeper do
  #  controllers applications: "oauth/applications"
  #end

  resources :certificates

  resources :courses, param: :course_id do
    member do
      post 'semester'
      get 'roster', to: 'courses#roster'
      get 'queue', to: 'courses/queue#show'
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
      get 'open', to: "courses/open#show"
      get 'database', to: "courses/database#index", as: :database
      get 'recent_activity', to: "summaries#recent_activity"
    end
  end

  get 'landing', to: 'landing#index'
  get 'about', to: 'landing#about'

  get '/users/auth/google_oauth2/callback', to: 'oauth_accounts#create_or_update', constraints: lambda { |req|
    req.env['omniauth.origin'] !~ /login/
  }
  get '/users/auth/failure', to: 'oauth_accounts#error', constraints: lambda { |req|
    req.env['omniauth.origin'] !~ /login/
  }

  devise_scope :user do
    get 'auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2'
    get 'auth/test/callback', to: 'users/omniauth_callbacks#test'
    get 'auth/failure', to: 'users/omniauth_callbacks#failure'
    get 'sign_in', to: 'landing#index', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root to: 'landing#index'
end
