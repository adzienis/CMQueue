# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  namespace :admin do
    namespace :courses do
      resources :registrations, only: [:index, :update] do
        collection do
          get "search", to: "registrations#index"
        end
      end
    end
    resources :courses do
      collection do
        get "search"
      end
    end
  end

  resource :admin do
  end

  get "accounts/index"
  namespace :courses do
    get "questions/edit"
    get "questions/update"
  end
  namespace :courses do
    namespace :queue do
      get "staff_log/show"
    end
  end
  namespace :users do
    get "settings/index"
    get "settings/update"
  end
  authenticate :user, ->(u) { u.has_role? :admin } do
    mount Sidekiq::Web => "/admin/sidekiq"
  end

  namespace :analytics do
    namespace :metabase do
      resources :dashboards
    end
  end
  resource :account, except: [:destroy, :create] do
    resources :settings, controller: "accounts/settings"
  end

  namespace :forms do
    resource :question, only: [:new, :create, :edit, :update, :destroy], controller: :question
    namespace :analytics do
      resources :dashboards, only: [:new, :create, :edit, :update, :destroy], controller: :dashboard
    end
  end

  namespace :courses do
    get "answer/show"
  end
  post "enroll", to: "forms/enroll_by_code#create"
  namespace :courses do
    get "queue/index"
  end
  get "activity", to: "summaries#activity"
  get "answer_time", to: "summaries#answer_time"
  get "grouped_tags", to: "summaries#grouped_tags"

  resources :tag_groups

  get "/api/swagger", to: "application#swagger", as: :swagger
  get "/demo", to: redirect("https://cmqueue-demo.herokuapp.com/"), as: :demo

  # mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount PgHero::Engine, at: "pghero"

  resource :user, as: :current_user, user_scope: true do
    resources :enrollments, controller: "users/enrollments"
  end

  resources :tags do
    collection do
      get "download", to: "tags#download_form"
      post "import", to: "tags#import"
    end
  end
  resources :question_states

  resources :messages

  resources :settings
  resources :notifications do
    member do
      patch "read", to: "notifications/read#update"
    end
  end
  scope module: :enrollments do
    get "enroll_by_search/new", to: "enroll_by_search#new", as: "new_enroll_by_search"
    post "enroll_by_search", to: "enroll_by_search#create", as: "enroll_by_search"
    post "enroll_by_code", to: "enroll_by_code#create", as: "enroll_by_code"
    get "enroll_by_code/new", to: "enroll_by_code#new", as: "new_enroll_by_code"
  end

  resources :enrollments do
    collection do
      get "download", to: "enrollments#download_form"
      post "import", to: "enrollments/import#create"
      get "import", to: "enrollments/import#index"
    end
  end

  resources :roles

  resources :questions, shallow: true, only: [] do
    resources :messages
    resources :question_states
    member do
      post "handle", to: "questions/handle#create"
    end
  end

  resources :questions do
    member do
      get "paginatedPreviousQuestions", to: "questions#paginated_previous_questions"
      get "previousQuestions", to: "questions#previous_questions"
      post "acknowledge", to: "questions#acknowledge"
      post "update_state", to: "questions#update_state"
      patch "acknowledge", to: "questions/acknowledge#update"
    end
    collection do
      get "download", to: "questions#download_form"
      get "position", to: "questions#position"
    end
  end

  resources :courses

  resources :users, only: [], model_name: "User" do
    resources :settings, controller: "users/settings"
  end

  resources :users do
    member do
      get "impersonate", to: "users/impersonate#start_impersonating"
    end
    collection do
      get "stop_impersonating", to: "users/impersonate#stop_impersonating"
      get "authenticated", to: "users/authenticated#show"
    end
  end

  namespace :courses do
    resources :registrations, only: [:new, :create, :update], controller: "registrations"
  end

  resources :courses, only: [], model_name: "Course" do
    member do
      scope :analytics do
        get "dashboards/custom", to: "dashboards/custom#show"
      end
    end

    namespace :analytics do
      resources :dashboards
    end
    resources :questions, except: [:new, :create], controller: "courses/questions" do
      collection do
        get "download", to: "questions#download_form"
        get "search", to: "questions/search#index"
        get "count", to: "questions/count#show"
      end
      member do
        post "handle", to: "questions/handle#create"
      end
    end

    resources :tags do
      collection do
        get "download", to: "tags#download_form"
        get "search", to: "tags/search#index"
      end
    end

    namespace :forms do
      resource :question, only: [:new, :create, :edit, :update, :destroy], controller: :question
      namespace :analytics do
        resources :dashboards, only: [:new, :create, :edit, :update, :destroy], controller: :dashboard
      end
    end

    resources :tag_groups do
      collection do
        get "search", to: "tag_groups/search#index"
      end
    end

    resources :users, controller: "courses/users"

    resources :question_states

    resources :messages

    resources :settings, controller: "courses/settings"

    resources :certificates do
      collection do
        get "download", to: "certificates#download"
      end
    end

    resources :enrollments do
      collection do
        get "search", to: "enrollments/search#index"
        get "import", to: "enrollments/import#index"
        post "import", to: "enrollments/import#create"
        get "download", to: "enrollments#download_form"
      end
    end
    resources :roles
  end

  resources :certificates

  resources :courses do
    resources :user_invitation, only: [:new, :create], controller: "forms/courses/user_invitation"
    resources :queue_status_logs, only: [:index], controller: "courses/queue_status_log"
    member do
      post "feed", to: "courses/feed#index"
      get "feed", to: "courses/feed#index"
      post "feed/answer", to: "courses/feed#answer"
      get "queued_questions", to: "courses/queued_questions#index"
      get "current_question", to: "courses/current_question#show"
      post "semester"
      get "roster", to: "courses#roster"
      get "queue", to: "courses/queue#show"
      get "queue/staff_log", to: "courses/queue/staff_log#show"
      get "settings/queues", to: "courses#queues"
      get "activeTAs", to: "courses#active_tas"
      get "analytics", to: "courses/analytics#index"
      get "analytics/today", to: "courses/analytics#today"
      get "analytics/tas", to: "courses/analytics#tas"
      get "settings/course", to: "courses/settings#index"
      post "answer", to: "courses#answer"
      get "answer", to: "courses/answer#show"
      get "answer/question", to: "courses/answer#show", as: :answer_question
      get "answer/previousQuestions", to: "courses#answer_page"
      post "putBack", to: "courses#putBack"
      post "finishAnswering", to: "courses#finishAnswering"
      post "freeze", to: "courses#freeze"
      post "kick", to: "courses#kick"
      get "topQuestion", to: "courses#top_question"
      get "open", to: "courses/open#show"
      patch "open", to: "courses/open#update"
      get "database", to: "courses/database#index", as: :database
      get "recent_activity", to: "summaries#recent_activity"
      get "questions_count", to: "courses/questions_count#show"
    end
  end

  get "landing", to: "landing#index"
  get "about", to: "landing#about"

  get "/users/auth/google_oauth2/callback", to: "oauth_accounts#create_or_update", constraints: lambda { |req|
    req.env["omniauth.origin"] !~ /login/
  }
  get "/users/auth/failure", to: "oauth_accounts#error", constraints: lambda { |req|
    req.env["omniauth.origin"] !~ /login/
  }

  devise_scope :user do
    get "auth/google_oauth2/callback", to: "users/omniauth_callbacks#google_oauth2"
    get "auth/test/callback", to: "users/omniauth_callbacks#test"
    get "auth/failure", to: "users/omniauth_callbacks#failure"
    get "sign_in", to: "landing#index", as: :new_user_session
    get "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session
  end
  devise_for :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks"}

  root to: "landing#index"
end
