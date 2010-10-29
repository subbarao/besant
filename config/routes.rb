Tweet2review::Application.routes.draw do

  match '/movies/:id/:action/:page' => 'movies'

  resources :movies do

    collection do
      get :autocomplete
    end

    member do
      get :sync
      get :positive
      get :negative
      get :mixed
      get :fresh
      get :terminate
      get :spotlight
      get :edit_positive
      get :edit_negative
      get :edit_mixed
      get :edit_fresh
      get :edit_external
      get :edit_spotlight
      get :edit_terminate
    end
    resources :keywords
  end

  resources :keywords

  match '/media(/:dragonfly)', :to => Dragonfly[:images]

  match 'login' =>   'application#login'

  match 'logout' =>  'application#logout'

  root :to => "movies#index"
end
