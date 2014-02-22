GtGraphics::Application.routes.draw do
  resource :sitemap, controller: :page_sitemaps, only: :show
    
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

        resource :account, except: [:new, :create, :show] do
          get :edit_password
          patch :update_password
          patch :update_preferences
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
          resources :styles, controller: :image_styles, except: [:index, :show] do
            member do
              get :crop
              patch :apply_crop
            end
          end
          collection do
            patch :batch, as: :batch_process
            delete :destroy_multiple
            get :translation_fields
          end
          member do
            get :context_menu
            get :crop
            patch :crop, action: :apply_crop
            patch :uncrop
            get :download
            get :dimensions
            patch :move_to_attachments
          end
        end

        resources :messages, only: [:index, :show, :destroy] do
          collection do
            delete :destroy_multiple
          end
          member do
            patch :toggle
          end
        end

        resources :pages do
          resources :children, controller: :pages, only: :new
          collection do
            get :embeddable_fields
            get :embeddable_translation_fields
            get :preview_path
            get :translation_fields
            get :tree
          end
          member do
            patch :move
            patch :move_up
            patch :move_down
            patch :publish
            patch :hide
            patch :enable_in_menu
            patch :disable_in_menu
          end
        end

        resources :redirections, only: [] do
          get :translation_fields, on: :collection
        end

        resources :shouts

        resources :snippets, except: :show do
          collection do
            delete :destroy_multiple
            get :translation_fields
          end
        end
        
        resources :templates do
          collection do
            delete :destroy_multiple
            get :translation_fields
            get :files_fields
          end
          member do
            delete 'destroy_region/:label', action: :destroy_region, as: :destroy_region
          end
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

      Page::EMBEDDABLE_TYPES.each do |page_type|
        page_embeddable_class = page_type.constantize
        resource_name = page_embeddable_class.resource_name

        actions = { show: :get, edit: :get }
        case resource_name
        when :contact_form then actions.merge!(show: [:get, :post])
        when :image then actions.merge!(download: :get)
        end

        scope constraints: Routing::PageConstraint.new(page_type) do
          controller_name = resource_name.to_s.pluralize
          actions.each do |action_name, request_methods|
            if action_name == :show
              match '*path(.:format)', controller: controller_name, action: action_name, via: request_methods, as: resource_name
            else
              match "*path/#{action_name}(.:format)", controller: controller_name, action: action_name, via: request_methods, as: "#{action_name}_#{resource_name}"
            end
          end
        end
        
        root "#{resource_name.to_s.pluralize}#show", as: nil, constraints: Routing::RootPageConstraint.new(page_type)      
      end

      root to: 'homepages#show'

      # Legacy URLs that have changed permanently (HTTP 301)
      get 'image/:slug', constraints: Routing::Legacy::ImageConstraint.new, to: redirect { |params, request|
        page = Page.images.find_by!(slug: params[:slug])
        "/#{page.path}"
      }
      get 'category/:slug(/:page)', constraints: Routing::Legacy::CategoryConstraint.new, page: /\d/, to: redirect { |params, request|
        slug = params[:slug].split(',').first
        page = Page.find_by!(slug: slug)
        url = "/#{page.path}"
        page_index = params[:page].to_i
        url << "?page=#{page_index}" if page_index > 1
        url
      }

      # This route is a workaround throwing a routing error that can be caught by a controller
      get '*path' => 'errors#unmatched_route'
    end
  end
end