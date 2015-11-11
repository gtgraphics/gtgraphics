Rails.application.routes.draw do
  concern :autocompletable do
    collection do
      get :autocomplete
    end
  end

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

  concern :taggable do
    member do
      patch :tag
      patch :untag
    end
  end

  concern :batch_processable do
    collection do
      patch :batch, action: :batch_process, as: :batch_process
    end
  end

  get 'sitemap.xml', to: 'sitemaps#index', as: :sitemaps, format: 'xml'
  get 'sitemap.:page.xml', to: 'sitemaps#show', as: :sitemap, format: 'xml'

  # Downloads
  scope 'files', constraints: { filename: /.*/ } do
    get 'images/download/:filename' => 'image/styles#download', as: :download_image_style
    get 'download/:filename' => 'attachments#download', as: :download_attachment
    get ':filename' => 'attachments#show', as: :attachment
  end

  scope '(:locale)', constraints: { locale: /[a-z]{2}/ } do
    scope constraints: Router::LocaleConstraint.new do
      namespace :admin do
        scope controller: :sessions do
          get :login, action: :new
          post :login, action: :create
          match :logout, action: :destroy, via: %i(get delete)
        end

        scope '(:translations)', constraints: { translations: /[a-z]{2}/ } do
          scope constraints: Router::LocaleConstraint.new(:translations) do
            get :search, controller: :search, action: :show

            namespace :editor do
              with_options only: [:show, :create, :update] do |r|
                r.resource :link
                r.resource :image
              end
            end

            namespace :stats do
              get 'disk_usage', to: 'disk_usage#index', as: :disk_usage

              scope :traffic, controller: :traffic do
                root action: :index, as: :traffic
                patch :reset, as: :reset_traffic
              end

              scope :downloads, controller: :downloads do
                root action: :index, as: :downloads
                scope '(:type)' do
                  get :total, as: :total_downloads
                  get ':year/:month', action: :month, as: :monthly_downloads, year: /[0-9]+/, month: /[0-9]+/
                  get ':year', action: :year, as: :yearly_downloads, year: /[0-9]+/
                end
                get :referers, as: :download_referers
              end

              scope :visits, controller: :visits do
                root action: :index, as: :visits
                get :total, as: :total_visits
                get ':year/:month', action: :month, as: :monthly_visits, year: /[0-9]+/, month: /[0-9]+/
                get ':year', action: :year, as: :yearly_visits, year: /[0-9]+/
              end
            end

            resource :account, except: %i(new create) do
              get :edit_password
              patch :update_password
              patch :update_preferences
            end

            resources :attachments, except: %i(new create show),
                                    concerns: :batch_processable do
              collection do
                match :upload, via: %i(post patch)
              end
              member do
                get :download
              end
              patch :convert_to_image, on: :member
            end

            resources :clients, only: %i(index edit update)

            resources :images, except: %i(new create), concerns: [:autocompletable,:customizable, :batch_processable, :taggable] do
              resources :styles, controller: :'image/styles', concerns: [:customizable, :movable, :batch_processable] do
                collection do
                  match :upload, via: %i(post patch)
                  delete :destroy_multiple
                end
              end
              resources :attachments, as: :attachments, controller: :'image/attachments', concerns: %i(movable batch_processable) do
                match :upload, on: :collection, via: %i(post patch)
              end
              resources :shop_links, controller: :'image/shop_links', except: %i(index show)
              collection do
                match :upload, via: %i(post patch)
                patch :associate_owner, action: :associate_owner, as: :associate_owner_with
                patch :associate_tags, action: :associate_tags, as: :associate_tags_with
              end
              member do
                get :pages
                get :download
                get :dimensions
                patch :convert_to_attachment
              end
            end

            resources :projects, concerns: [:autocompletable, :batch_processable, :taggable] do
              resources :images, controller: :'project/images', only: :destroy, concerns: [:movable, :batch_processable] do
                collection do
                  match :upload, via: %i(post patch)
                end
              end
              member do
                get :pages
                get :assign_images, as: :assign_images_to
                post :assign_images, action: :attach_images, as: :attach_images_to
              end
            end

            resources :providers, except: :show

            resources :messages, only: [:index, :show, :destroy] do
              collection do
                delete :destroy_multiple
              end
              member do
                patch :mark_read
                patch :mark_unread
              end
            end

            resources :pages, except: :new, concerns: [:autocompletable, :movable] do
              resources :children, controller: :pages, only: :new do
                get ':page_type', on: :new, action: :new, as: :typed
              end
              resources :regions, controller: :'page/regions', only: [:index, :edit, :update, :destroy] do
                patch :update_multiple, on: :collection
              end
              resource :image, controller: :'page/images', only: %i(new create)
              resource :contact_form, controller: :'page/contact_forms', only: [:edit, :update]
              resource :project, controller: :'page/projects', only: %i(new create)
              resource :redirection, controller: :'page/redirections', only: [:edit, :update]
              collection do
                get :tree
              end
              member do
                patch :move
                patch :publish
                patch :hide
                patch :enable_in_menu
                patch :disable_in_menu
                patch 'change_template/:template_id', action: :change_template, as: :change_template
              end
            end

            resources :redirections, only: [] do
              get :translation_fields, on: :collection
            end

            resources :tags, only: :index

            resources :templates, except: :new, concerns: :movable do
              resources :region_definitions, controller: :'template/region_definitions', except: [:index, :show], concerns: :movable
              get ':template_type', on: :new, action: :new, as: :typed
              collection do
                get 'types/:template_type', action: :index, as: :typed
                delete :destroy_multiple
              end
              member do
                delete 'destroy_region/:label', action: :destroy_region, as: :destroy_region
              end
            end

            resources :users do
              resources :social_links, controller: :'user/social_links', except: :show, concerns: :movable
              member do
                get :edit_password
                patch :update_password
              end
            end

            root to: redirect('/admin/pages')
          end
        end
      end

      # Legacy URLs that have changed permanently (HTTP 301)
      get 'image/:slug', to: redirect { |params, request|
        page = Page.images.find_by!('slug = ?', params[:slug])
        "/#{page.path}"
      }
      get 'category/:slug(/:page)', page: /\d/, to: redirect { |params, request|
                                      slug = params[:slug].split(',').first
                                      page = Page.contents.find_by!('slug = ?', slug)
                                      url = "/#{page.path}"
                                      page_index = params[:page].to_i
                                      url << "?page=#{page_index}" if page_index > 1
                                      url
                                    }

      get 'pic-:slug.:format', to: redirect { |params, request|
        page = Page.images.find_by!('slug = ?', params[:slug])
        page.image.asset.url(:public)
      }

      # Permalinks
      get ':id' => 'page/permalinks#show', as: :page_permalink, id: /[A-Z0-9]{6}/i
    end
  end
end
