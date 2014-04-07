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
          with_options only: [:show, :create, :update] do |r|
            r.resource :link
            r.resource :image
          end
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
          resources :styles, controller: :image_styles, except: :index do
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
          resources :regions, controller: :page_regions, only: [:show, :update] do
            collection do
              patch :update_multiple
            end
          end
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
            get :editor_preview
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
        controller_name = resource_name.to_s.pluralize

        actions = {
          show: { via: :get },
          edit: { via: :get }
        }
        case resource_name
        when :contact_form then actions.merge!(show: { via: [:get, :post] })
        when :image then actions.merge!('download(/:style_id(/:dimensions))' => { action: :download, via: :get, as: :download_image })
        end

        scope constraints: Routing::PageConstraint.new(page_type) do
          actions.each do |action_name, options|
            options = options.reverse_merge(controller: controller_name, action: action_name, via: :get)
            if action_name == :show
              match '*path(.:format)', options.reverse_merge(as: resource_name)
            else
              match "*path/#{action_name}(.:format)", options.reverse_merge(as: "#{action_name}_#{resource_name}")
            end
          end
        end
        
        scope constraints: Routing::RootPageConstraint.new(page_type) do
          actions.each do |action_name, options|
            options = options.reverse_merge(controller: controller_name, action: action_name, via: :get).merge(as: nil)
            if action_name == :show
              root options
            else
              match "#{action_name}(.:format)", options
            end
          end
        end
      end

      get 'edit' => 'homepages#edit', as: :edit_root
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