GtGraphics::Application.routes.draw do
  scope '(:locale)', constraints: { locale: /[a-z]{2}/ } do
    scope constraints: Routing::LocaleConstraint.new do
      namespace :admin do
        scope controller: :sessions do
          get :sign_in, action: :new
          post :sign_in, action: :create
          match :sign_out, action: :destroy, via: [:get, :delete]
        end

        namespace :editor do
          resource :link, only: [:show, :update]
          resource :image, only: [:show, :update]
        end

        resource :account, except: [:new, :create] do
          get :edit_password
          patch :update_password
        end

        resources :attachments do
          collection do
            delete :destroy_multiple
            get :translation_fields
          end
          member do
            get :download
            patch :move_to_images
          end
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
            patch :move_to_attachments
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
            patch :move_up
            patch :move_down
            patch :toggle_menu_item
            patch :publish
            patch :draft
            patch :hide
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

        resources :users do
          member do
            get :edit_password
            patch :update_password
          end
        end 
        
        #root 'dashboard#index'
        root to: redirect('/admin/pages')
      end

      scope '/', constraints: { id: /[^.]*/ } do
        with_options path: '/', only: :show do |route|
          route.resources :contents, constraints: Routing::PageConstraint.new('Content')
          route.resources :galleries, constraints: Routing::PageConstraint.new('Gallery')
          route.resources :homepages, constraints: Routing::PageConstraint.new('Homepage')
          route.resources :images, constraints: Routing::PageConstraint.new('Image') do
            get :download, on: :member
          end
          route.resources :redirections, constraints: Routing::PageConstraint.new('Redirection')
          route.resources :contact_forms, constraints: Routing::PageConstraint.new('ContactForm') do
            resource :message, controller: :contact_messages, as: :messages, only: [:new, :create]
          end
        end
      end

      %w(Content Gallery Homepage Image Redirection ContactForm).each do |page_type|
        root "#{page_type.underscore.pluralize}#show", as: nil, constraints: Routing::RootPageConstraint.new(page_type)
      end
      root to: redirect('/404')
    end
  end

  # Legacy URLs that have changed permanently (HTTP 301)
  #get '/category/:types/:page', to: redirect { |params, request|
  #  type = params[:types].split(',').first.downcase
  #  url = "/albums/#{type}"
  #  page = params[:page].presence.try(:to_i)
  #  if page and page > 1
  #    url << "?page=#{page}"
  #  else
  #    url
  #  end
  #}

end