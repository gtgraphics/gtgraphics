class Page < ActiveRecord::Base
  module UrlAccessible
    extend ActiveSupport::Concern

    RESERVED_SLUGS = [].freeze
    RESERVED_PATHS = %w(401 404 500 system public assets files static).freeze

    PERMALINK_CHARS = [('A'..'Z'), ('a'..'z'), ('0'..'9')].freeze
    PERMALINK_LENGTH = 6

    included do
      include Sluggable

      has_slug :slug, param: false, from: -> { root? ? '' : title(I18n.default_locale) }, if: :generate_slug?

      validates :slug, presence: { unless: :root? }, exclusion: { in: RESERVED_SLUGS, allow_blank: true }, uniqueness: { scope: :parent, if: :slug_changed? }
      validates :path, presence: { unless: :root? }, exclusion: { in: RESERVED_PATHS, allow_blank: true }, uniqueness: { if: :path_changed? }
      validates :permalink, presence: true, length: { is: PERMALINK_LENGTH, allow_blank: true }, strict: true
   
      before_validation :set_path, if: :generate_path?
      before_validation :set_permalink, unless: :permalink?, on: :create
      around_save :update_descendants_paths
    end

    module ClassMethods
      def generate_permalink
        RandomString.generate(PERMALINK_LENGTH, chars: PERMALINK_CHARS)
      end
    end

    def set_next_available_slug(slug = self.generate_slug)
      raise 'no initial slug defined' if slug.nil?
      self.slug = slug
      while self.class.where(parent_id: parent_id, slug: self.slug).exists?
        self.slug = self.slug.next
      end
    end

    def refresh_path!(include_descendants = false)
      if include_descendants
        transaction { self_and_descendants.each(&:refresh_path!) }
      else
        update_attribute(:path, generate_path)
      end
    end

    private
    def generate_path
      if parent.present?
        path_parts = parent.self_and_ancestors.pluck(:slug) << slug.to_s
      else
        path_parts = [slug.to_s]
      end
      path_parts.reject!(&:blank?)
      File.join(path_parts)
    end

    def generate_path?
      slug_changed? or parent_id_changed?
    end

    def generate_slug?
      new_record? and slug.blank? and title(I18n.default_locale).present?
    end

    def set_path
      self.path = generate_path
    end

    def set_permalink
      self.permalink = self.class.generate_permalink
    end

    def update_descendants_paths
      path_changed = self.path_changed?
      yield
      transaction { descendants.each(&:refresh_path!) } if path_changed
    end
  end
end