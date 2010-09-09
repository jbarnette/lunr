require "sunspot"

module Sunspot
  module DSL
    class Fields
      def property name, type, options = {}
        @setup.clazz.properties[name] = type
        send type, name, options.merge(:stored => true)
      end
    end
  end

  module Search
    class Hit
      alias_method :original_initialize, :initialize

      def initialize *args
        original_initialize(*args)

        if clazz = Sunspot::TypeField.aliases_inverted[@class_name]
          @class_name = clazz.name
        end
      end
    end
  end

  module Type
    class BooleanType
      def cast thing
        thing == "true" ? true : thing == "false" ? false : !!thing
      end
    end
  end

  class TypeField
    class << self
      def alias(dest_class, source_class_name)
        @@inverted = nil # invalidate cache
        aliases[dest_class] = source_class_name
      end

      def aliases
        @@aliases ||= {}
      end

      def aliases_inverted
        @@inverted ||= aliases.invert
      end
    end

    alias_method :old_to_indexed, :to_indexed

    def to_indexed clazz
      self.class.aliases[clazz] || clazz.name
    end
  end
end
