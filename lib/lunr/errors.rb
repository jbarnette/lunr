module Lunr
  class Error < StandardError
  end

  class AlreadyExecuted < Error
    attr_reader :search

    def initalize search
      @search = search
      super "Can't add more criteria, this search has already been executed!"
    end
  end

  class BadModel < Error
    def initialize klass
      super "#{klass.name} doesn't include Lunr::Model!"
    end
  end
end
