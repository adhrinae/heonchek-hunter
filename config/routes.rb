Rails.application.routes.draw do
  root 'used_books#index'

  get 'search' => 'used_books#results'
end
