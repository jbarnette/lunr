require "lunr/model/klass"

module Lunr
  module Model
    attr_accessor :id

    def to_h
      @to_h ||= {}.tap do |h|
        h[:id] = id

        self.class.properties.each do |name, type|
          h[name] = send name
        end
      end
    end
  end
end
