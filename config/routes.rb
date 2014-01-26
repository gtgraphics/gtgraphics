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
          collection do
            delete :destroy_multiple
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

=begin
        case resource_name
        when :contact_form

          get '*path', to: "#{resource_name.to_s.pluralize}#show", Routing::PageConstraint.new(page_type)

          resource(resource_name, page_options.merge(only: :edit)) do
            #resource
          end
        when :image
          resource(resource_name, page_options) do
            get :download
          end
        else
          resource(resource_name, page_options)
        end
=end
        
      end
      root to: 'homepages#show'
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