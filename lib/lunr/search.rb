require "lunr/errors"
require "lunr/model"
require "lunr/sunspot"

module Lunr
  class Search
    include Enumerable

    attr_reader :klass

    def initialize klass, &block
      raise Lunr::BadModel.new(klass) unless klass < Lunr::Model

      @executed = false
      @klass    = klass
      @search   = Sunspot.new_search klass

      all = @klass.scopes[:all]

      scope &all   if all
      scope &block if block_given?
    end

    def each &block
      execute && @results.each(&block)
    end

    def empty?
      0 == total
    end

    def executable!
      raise Lunr::AlreadyExecuted.new(self) if executed?
    end

    def executed?
      @executed
    end

    def method_missing sym, *args
      return super unless scope = klass.scopes[sym]

      executable!

      dsl = @search.send :dsl

      if args.empty?
        dsl.instance_eval &scope
      else
        scope.call dsl, args
      end

      self
    end

    def page
      @page ||= execute && @search.query.page
    end

    def pages
      total / per +
        (total_entries % per_page > 0 ? 1 : 0)
    end

    def params
      @search.query.to_params
    end

    def per
      @per ||= execute && @search.query.per_page
    end

    def respond_to sym, include_private = false
      klass.scopes.key?(sym) || super
    end

    def scope &block
      executable!
      @search.build &block
    end

    def total
      @total ||= execute && @search.total
    end

    alias_method :size, :total

    # Quack like WillPaginate::Collection

    alias_method :current_page,  :page
    alias_method :per_page,      :per
    alias_method :total_entries, :total
    alias_method :total_pages,   :pages

    private

    def execute
      unless @executed
        @executed = true
        @search.execute

        @results = @search.hits.map do |hit|
          # FIX: this belongs in the model.
          klass.new.tap do |model|
            model.instance_variable_set :"@id", hit.primary_key

            klass.properties.each do |name, type|
              value = hit.stored name

              # For text fields, which always appear to be multiple.

              if Array === value && value.length == 1 && type == :text
                value = value.first
              end

              model.instance_variable_set :"@#{name}", value
            end
          end
        end
      end

      true
    end
  end
end
