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

        resource :account, except: [:new, :create] do
          get :edit_password
          patch :update_password
          patch :update_preferences
        end

        resources :attachments do
          collection do
            # get 'sort/:sort/:direction', action: :index
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
            get :new_attachment, on: :collection
          end
          collection do
            # get 'sort/:sort/:direction', action: :index
            patch :batch, as: :batch_process
            delete :destroy_multiple
            get :translation_fields
          end
          member do
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
            # get 'sort/:sort/:direction', action: :index
            delete :destroy_multiple
          end
          member do
            patch :toggle
          end
        end

        resources :pages do
          collection do
            get :preview_path
            get :embeddable_fields
            get :embeddable_translation_fields
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

        resources :snippets, except: :show do
          collection do
            delete :destroy_multiple
            get :translation_fields
          end
        end
        
        resources :templates do
          resources :regions, controller: :region_definitions, as: :region_definitions, only: [:new, :create, :edit, :update, :destroy]
          collection do
            delete :destroy_multiple
            get :translation_fields
            get :files_fields
          end
          patch :make_default, on: :member
        end

        resources :users do
          collection do
            # get 'sort/:sort/:direction', action: :index
          end
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
        page_options = { path: '*path', constraints: Routing::PageConstraint.new(page_type), only: :show }
        case resource_name
        when :contact_form
          resource(resource_name, page_options.merge(only: [:show, :create]))
        when :image
          resource(resource_name, page_options) do
            get :download
          end
        else
          resource(resource_name, page_options)
        end
        root "#{resource_name.to_s.pluralize}#show", as: nil, constraints: Routing::RootPageConstraint.new(page_type)
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