require "configlet"
require "rsolr"

require "lunr/error"

module Lunr
  extend Configlet
  
  # Duh.
  VERSION = "1.0.0"

  config :lunr do
    default :pp  => "25"
    default :url => "http://localhost:8983/solr"
  end

  def self.search query, options = {}, &block
    page = [1, Integer(options[:p] || 0)].max
    per  = Integer options[:pp] || self[:pp]

    params = {
      :q    => query,
      :rows => per,
      :start => per * (page - 1),
    }

    begin
      raw = solr.select params
    rescue Errno::ECONNREFUSED => e
      raise Lunr::Error, "Can't connect to #{self[:url]}: #{e}"
    end

    header   = raw["responseHeader"]
    response = raw["response"]

    unless status = header["status"]
      raise Lunr::Error, "Bad (and cryptic) response status: #{status}"
    end

    docs  = response.delete "docs"
    total = response.delete "numFound"

    docs = block_given? ? docs.map(&block) : docs

    if defined? WillPaginate::Collection
      old = docs
      docs = WillPaginate::Collection.new page, per, total
      docs.replace old
    end

    docs
  end

  def self.solr
    @solr ||= RSolr.connect :url => self[:url]
  end
end
