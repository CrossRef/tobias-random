require 'bundler/setup'
require 'sinatra'
require 'json'
require 'mongo'

require_relative 'lib/tobias-random/config'

DOI_TYPES = %w{journal_article journal_issue journal conference_paper
                book book_series book_set content_item dissertation
                report_paper series standard standard_series dataset}

configure do
  set :dois, TobiasRandom::Config.dois

  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      set :dois, TobiasRandom::Config.dois
    end
  end
end

helpers do
  def json content
    content_type 'application/json'
    status 200
    content.to_json
  end

  def doi_query count, query_data
    query_data[:random_index] = {'$gte' => rand}
    options = {
      :limit => count,
      :sort => [:random_index, 1]
    }
    docs = settings.dois.find(query_data, options)

    unless docs.has_next?
      query_data[:random_index] = {'$lt' => rand}
      docs = settings.dois.find(query_data, options)
    end

    docs.map { |doc| doc['doi'] }
  end
end

get '/dois' do
  count = 20
  query = {}

  if params.key? 'count'
    count = [1000, params['count'].to_i].min
    count = [0, count].max
  end

  if params.key? 'type'
    if DOI_TYPES.include? params['type']
      query[:type] = params['type']
    else
      halt 'Invalid type. See /types for valid types.'
    end
  end

  if params.key? 'title'
    query[:type] = 'journal_article' # or conf proc
    query['journal.full_title'] = params['title']
  elsif params.key? 'issn'
    query[:type] = 'journal_article'
    query['journal.p_issn'] = params['issn']
  end

  if params.key? 'to'
    query['published.year'] = {'$lte' => params['to'].to_i}
  end

  if params.key? 'from'
    query['published.year'] = {'$gte' => params['from'].to_i}
  end

  json doi_query(count, query)
end

get '/types' do
  json DOI_TYPES
end

get '/' do
  haml :index
end
