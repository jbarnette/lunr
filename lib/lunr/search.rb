require "lunr/errors"
require "lunr/model"
require "lunr/sunspot"

module Lunr
  class Search
    include Enumerable

    def each &block
      execute && @results.each(&block)
    end

    def total
      execute && @search.total
    end

    alias_method :size, :total

    def empty?
      0 == total
    end

    # Acting like WillPaginate::Collection

    def current_page
      execute && @search.query.page
    end

    def per_page
      execute && @search.query.per_page
    end

    def total_entries
      total
    end

    def total_pages
      total_entries / per_page +
        (total_entries % per_page > 0 ? 1 : 0)
    end

    attr_reader :klass

    def initialize klass, &block
      raise Lunr::BadModel.new(klass) unless klass < Lunr::Model

      @executed = false
      @klass    = klass
      @search   = Sunspot.new_search klass, &block

      if all = @klass.scopes[:all]
        scope &all
      end
    end

    def scope &block
      executable!
      @search.build &block
    end

    def executable!
      raise Lunr::AlreadyExecuted.new(self) if executed?
    end

    def executed?
      @executed
    end

    # :nodoc:

    def params
      @search.query.to_params
    end

    def method_missing sym, *args
      super unless scope = klass.scopes[sym]

      executable!

      dsl = @search.send :dsl

      if args.empty?
        dsl.instance_eval &scope
      else
        scope.call dsl, args
      end

      self
    end

    def respond_to sym, include_private = false
      klass.scopes.key?(sym) || super
    end

    private

    def execute
      unless @executed
        @executed = true
        @search.execute

        @results = @search.hits.map do |hit|
          klass.new.tap do |model|
            model.instance_variable_set :"@id", hit.primary_key

            klass.properties.each do |prop|
              model.instance_variable_set :"@#{prop}", hit.stored(prop)
            end
          end
        end
      end

      true
    end
  end
end
