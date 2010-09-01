require "lunr/search"
require "lunr/sunspot"

module Lunr
  module Model
    def self.included klass
      klass.extend Klass
    end

    attr_reader :id

    module Klass
      def properties
        @properties ||= []
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

        properties.uniq.each do |prop|
          attr_reader prop
        end
      end
    end
  end
end
