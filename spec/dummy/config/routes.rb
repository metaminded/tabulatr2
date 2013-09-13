Rails.application.routes.draw do
  resources :products, only: [:index] do
    collection do
      get :simple_index
      get :one_item_per_page_with_pagination
      get :one_item_per_page_without_pagination
      get :count_tags
      get :stupid_array
    end
  end

  resources :vendors, only: [:index]
end
