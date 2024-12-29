Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'api/v1/users/sessions',
    registrations: 'api/v1/users/registrations'
  }

  namespace :api do
    namespace :v1 do      
      resources :products
    
      resource :cart, only: [:show] do
        post 'add_item', to: 'carts#add_item'
        delete 'remove_item', to: 'carts#remove_item'
      end
    
      resource :orders, only: %i[show create]
    end
  end
end


