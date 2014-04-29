class Activity
  module EmbedsManyExtension
    extend ActiveSupport::Concern

    module ClassMethods
      def embeds_many(association_name)
        singular_association_name = association_name.to_s.singularize
        options.reverse_merge!(class_name: association_name.to_s.classify)
        klass = options[:class_name]
   
        class_eval %{
          def #{association_name}
            @#{association_name} ||= (#{klass}.where(#{klass}.primary_key => #{singular_association_name}_ids) if #{singular_association_name}_ids.present?)
          end
   
          def #{association_name}=(objects)
            @#{association_name} = objects
            @#{singular_association_name}_ids = objects.collect { |object| object.send(#{klass}.primary_key) }
          end
   
          attribute :#{singular_association_name}_ids, Array[Integer]
   
          def #{singular_association_name}_ids=(ids)
            @#{association_name} = #{klass}.where(#{klass}.primary_key => ids)
            super
          end
        }
      end
    end
  end
end