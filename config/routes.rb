GtGraphics::Application.routes.draw do
  devise_for :users, skip: [:registrations]
  #devise_for :users, controllers: { sessions: 'admin/sessions' }

  scope '(:locale)', constraints: Routing::LocaleConstraint.new do
    namespace :admin do

      namespace :editor do
        resource :link, only: [:show, :update]
        resource :image, only: [:show, :update]
      end

      resource :account, except: [:new, :create]

      resources :attachments do
        collection do
          delete :destroy_multiple
          get :translation_fields
        end
        get :download, on: :member
      end

      resources :images do
        collection do
          patch :batch, as: :batch_process
          delete :destroy_multiple
          get :translation_fields
        end
        member do
          get :download
          get :dimensions
        end
      end

      resources :pages do
        collection do
          get :preview_path
          get :embeddable_fields
          get :embeddable_settings
          get :translation_fields
        end
        member do
          patch :toggle
          patch :move_up
          patch :move_down
        end
      end

      resources :redirections, only: [] do
        get :translation_fields, on: :collection
      end

      resources :shouts
      
      resources :templates do
        resources :regions, controller: :region_definitions, as: :region_definitions, only: [:new, :create, :edit, :update, :destroy]
        collection do
          get :translation_fields
          get :files_fields
        end
        patch :make_default, on: :member
      end

      resources :users      
      
      root 'dashboard#index'
    end

    scope '/', constraints: { id: /.*/ } do
      with_options path: '/', only: :show do |route|
        route.resources :contents, constraints: Routing::PageConstraint.new('Content')
        route.resources :galleries, constraints: Routing::PageConstraint.new('Gallery')
        route.resources :images, constraints: Routing::PageConstraint.new('Image') do
          get :download, on: :member
        end
        route.resources :redirections, constraints: Routing::PageConstraint.new('Redirection')
        route.resources :contact_forms, constraints: Routing::PageConstraint.new('ContactForm') do
          resource :message, controller: :contact_messages, as: :messages, only: [:new, :create]
        end
      end
    end

    %w(Content Gallery Image Redirection).each do |page_type|
      root "#{page_type.underscore.pluralize}#show", as: nil, constraints: Routing::PageConstraint.new(page_type)
    end
    root 'pages#show'
  end

  scope '/', constraints: { id: /.*/ } do
    with_options path: '/', only: :show do |route|
      route.resources :contents, constraints: Routing::PageConstraint.new('Content')
      route.resources :galleries, constraints: Routing::PageConstraint.new('Gallery')
      route.resources :images, constraints: Routing::PageConstraint.new('Image') do
        get :download, on: :member
      end
      route.resources :redirections, constraints: Routing::PageConstraint.new('Redirection')
      route.resources :contact_forms, constraints: Routing::PageConstraint.new('ContactForm') do
        resource :message, controller: :contact_messages, as: :messages, only: [:new, :create]
      end
    end
  end

  # TODO: ID-based URLs for Pages
  #get '/:id', constraints: Routing::PermalinkConstraint.new, to: redirect { |params, request|
  #  page = Page.find(params[:id])
  #  page_path(page)
  #}

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
