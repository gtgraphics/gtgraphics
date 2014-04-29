class Activity
  module EmbedsOneExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def embeds_one(association_name, options = {})
        options.reverse_merge!(class_name: association_name.to_s.classify)
        klass = options[:class_name]
   
        class_eval %{
          def #{association_name}=(object)
            @#{association_name} = object
            @#{association_name}_id = object.send(#{klass}.primary_key)
          end
   
          attribute :#{association_name}_id, Integer

          def #{association_name}
            @#{association_name} ||= (#{klass}.where(#{klass}.primary_key => #{association_name}_id).first if #{association_name}_id.present?)
          end
   
          def #{association_name}_id=(id)
            @#{association_name} = #{klass}.where(#{klass}.primary_key => id).first
            super
          end
        }
      end
    end
  end
end