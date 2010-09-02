require "lunr/search"
require "lunr/sunspot"

module Lunr
  module Model
    def self.included klass
      klass.extend Klass
    end

    module Klass
      def first &block
        search(&block).first
      end

      def properties
        @properties ||= {}
      end

      def scopes
        @scopes ||= {}
      end

      def scope sym = :all, &block
        scopes[sym] = block

        unless sym == :all
          class_eval <<-END, __FILE__, __LINE__ + 1
            def self.#{sym}; search.#{sym} end
          END
        end
      end

      def search &block
        Lunr::Search.new self, &block
      end

      alias_method :all, :search

      def searches classname, &block
        Sunspot::TypeField.alias self, classname
        Sunspot.setup self, &block

        properties.each do |name, type|
          attr_reader name
        end
      end
    end
  end
end
