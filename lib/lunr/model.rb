require "lunr/model/klass"

module Lunr
  module Model
    def initialize hash
      @hash = hash
    end

    def id
      @hash[:id]
    end

    def to_h
      @hash
    end
  end
end
