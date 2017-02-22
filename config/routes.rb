Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'results#index'
  resources :results do 
  	collection do
  		post 'point1'
  		post 'point2'
  		post 'point3'
  	end
  end
end
