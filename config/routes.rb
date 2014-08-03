GtGraphics::Application.routes.draw do
  concern :movable do
    member do
      patch :move_up
      patch :move_down
    end
  end

  concern :customizable do
    member do
      get :customize
      patch :customize, action: :apply_customization
    end
  end

  get 'sitemap.:format', to: 'sitemaps#index', as: :sitemaps
  get 'sitemap.:page.:format', to: 'sitemaps#show', as: :sitemap
  
  scope 'files', constraints: { filename: /.*/ } do
    get 'download/:filename' => 'attachments#download', as: :download_attachment
    get ':filename' => 'attachments#show', as: :attachment
  end

  scope '(:locale)', constraints: { locale: /[a-z]{2}/ } do
    scope constraints: Routing::LocaleConstraint.new do
      namespace :admin do
        scope controller: :sessions do
          get :login, action: :new
          post :login, action: :create
          match :logout, action: :destroy, via: [:get, :delete]
        end
            
        scope '(:translations)', constraints: { translations: /[a-z]{2}/ } do
          scope constraints: Routing::LocaleConstraint.new(:translations) do
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

            resources :attachments, except: :show do
              collection do
                patch :upload
                patch :batch, action: :batch_process, as: :batch_process
              end
              patch :convert_to_image, on: :member
            end

            resources :images, except: [:new, :create], concerns: :customizable do
              resources :styles, controller: :'image/styles', concerns: [:customizable, :movable] do
                collection do
                  match :upload, via: [:post, :patch]
                  patch :batch, action: :batch_process, as: :batch_process
                  delete :destroy_multiple
                end
              end
              collection do
                patch :upload
                patch :batch, action: :batch_process, as: :batch_process
                patch :associate_owner, action: :associate_owner, as: :associate_owner_with
              end
              member do
                get :pages
                get :download
                get :dimensions
                patch :convert_to_attachment
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

            resources :pages, except: :new, concerns: :movable do
              resources :children, controller: :pages, only: :new do
                get ':page_type', on: :new, action: :new, as: :typed
              end
              resources :regions, controller: :'page/regions', only: [:index, :edit, :update, :destroy] do
                patch :update_multiple, on: :collection
              end
              resources :images, controller: :'page/images', only: [:new, :create]
              resource :contact_form, controller: :'page/contact_forms', only: [:edit, :update]
              resource :project, controller: :'page/projects', only: [:edit, :update]
              resource :redirection, controller: :'page/redirections', only: [:edit, :update]
              collection do
                get :preview_path
                get :tree
              end
              member do
                patch :move
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
                get :editor_preview
              end
            end

            resources :tags, only: :index
            
            resources :templates, except: :new, concerns: :movable do
              resources :region_definitions, controller: :'template/region_definitions', except: [:index, :show], concerns: :movable
              get ':template_type', on: :new, action: :new, as: :typed
              collection do
                get 'types/:template_type', action: :index, as: :typed
                delete :destroy_multiple
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
        end
      end

      Routing::Cms::PageRouter.insert(self)
      root to: 'homepages#show'

      # Permalinks
      get ':id' => 'page/permalinks#show', as: :page_permalink

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

      # This route is a workaround for Error Pages by throwing a routing error that can be caught by a controller
      get '(*path)' => 'errors#unmatched_route'
    end
  end
end