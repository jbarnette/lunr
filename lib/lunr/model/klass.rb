require "lunr/search"
require "lunr/sunspot"

module Lunr
  module Model
    def self.included klass
      klass.extend Klass
    end

    module Klass
      def create hit
        hash = { :id => hit.primary_key }

        properties.each do |name, type|
          value = hit.stored name

          if Array === value && value.length == 1 && type == :text
            # For text fields, which always appear to be multiple.
            value = value.first
          end

          hash[name] = value
        end

        new hash
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
            def self.#{name}
              search.#{name}
            end
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
          class_eval <<-END, __FILE__, __LINE__ + 1
            def #{name}
              @hash[#{name.inspect}]
            end
          END

          alias_method "#{name}?", name if type == :boolean
        end
      end
    end
  end
end
