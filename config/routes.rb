Rails.application.routes.draw do

  resource :courses do
    member do
      get 'search', to: "courses#search"
    end
  end
  resources :questions
  resources :courses

  resource :users do
    resources :courses, controller: 'users/courses'
  end

  resource :user do
    resources :courses, controller: 'users/courses'
  end

  get 'landing/', to: "landing#index"
  root to: "landing#index"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
    get 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
end
