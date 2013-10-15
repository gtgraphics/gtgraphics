GtGraphics::Application.routes.draw do
  namespace :admin do
    root 'home#index'

    resources :albums do
      resources :images do
        collection do
          patch :batch, as: :batch_process
        end
      end
    end

    resources :images do
      collection do
        patch :batch, as: :batch_process
      end
      member do
        get :download
      end
    end

    resources :menu_items do
      collection do
        get :record_type_fields
      end
    end

    resources :pages do
      get :preview_path, on: :collection
    end
    
    resources :page_templates do
      patch :make_default, on: :member
    end
    
    resources :shouts
  end

  resources :albums
  resources :images
  resources :pages, path: '/', constraints: { id: /.*/ }
  root 'home#index'

  # Legacy URLs that have changed permanently (HTTP 301)
  get '/category/:types/:page', to: redirect { |params, request|
    type = params[:types].split(',').first.downcase
    url = "/albums/#{type}"
    page = params[:page].presence.try(:to_i)
    if page and page > 1
      url << "?page=#{page}"
    else
      url
    end
  }
  get '/image/:id', to: redirect('/images/%{id}')
  get '/shoutbox', to: redirect('/shouts')

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
