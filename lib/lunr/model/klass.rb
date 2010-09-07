require "lunr/search"
require "lunr/sunspot"

module Lunr
  module Model
    def self.included klass
      klass.extend Klass
    end

    module Klass
      def create hit
        new.tap do |instance|
          instance.id = hit.primary_key

          properties.each do |name, type|
            value = hit.stored name

            # For text fields, which always appear to be multiple.

            if Array === value && value.length == 1 && type == :text
              value = value.first
            end

            instance.send "#{name}=", value
          end

          instance.freeze
        end
      end

      def first &block
        search(&block).first
      end

      def properties
        @properties ||= {}
      end

      def scopes
        @scopes ||= {}
      end

      def scope name = :all, &block
        scopes[name] = block

        unless name == :all
          class_eval <<-END, __FILE__, __LINE__ + 1
            def self.#{name}; search.#{name} end
          END
        end
      end

      def search &block
        Lunr::Search.new self, &block
      end

      alias_method :all, :search

      def searches classname = nil, &block
        Sunspot::TypeField.alias self, classname if classname
        Sunspot.setup self, &block

        properties.each do |name, type|
          attr_accessor name
        end
      end
    end
  end
end
