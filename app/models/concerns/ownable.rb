module Ownable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_owner(*args, &block)
      include ActiveSupport::Configurable

      options = args.extract_options!
      name = args.first || :owner

      config_accessor(:owner_association_name) { name }
      config_accessor(:owner_column) { :"#{name}_id" }
      config_accessor(:default_owner_to_current_user) { true }
      config_accessor(:destroy_with_owner) { false }

      # Configure using a block or the options
      if block_given?
        configure(&block)
      else
        options.each do |key, value|
          send("#{key}=", value)
        end
      end

      include Extensions
    end
  end

  module Extensions
    extend ActiveSupport::Concern

    included do
      belongs_to owner_association_name.to_sym, class_name: 'User', foreign_key: owner_column.to_sym

      delegate :name, to: owner_association_name.to_sym, prefix: true, allow_nil: true

      if default_owner_to_current_user
        before_validation do
          send("#{owner_association_name}=", User.current) unless attributes[owner_column.to_s]
        end
      end

      scope :owned, -> { where.not(owner_column.to_sym => nil) }
      scope :ownerless, -> { where(owner_column.to_sym => nil) }
    end

    module ClassMethods
      def owned_by(user)
        where(owner_column.to_sym => user.id)
      end
    end

    def assign_owner(user)
      send("#{owner_association_name}=", user)
      save
    end

    def assign_owner!(user)
      send("#{owner_association_name}=", user)
      save!
    end

    def owned?
      !ownerless?
    end

    def owned_by?(user)
      attributes[owner_column.to_s] == user.id
    end

    def ownerless?
      attributes[owner_column.to_s].nil?
    end
  end
end