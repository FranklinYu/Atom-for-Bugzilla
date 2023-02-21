# frozen_string_literal: true

require 'open-uri'
require 'rss'
require 'socket'

require 'nokogiri'
require 'sinatra'

def get_name(user)
  if user[:name].nil? || user[:name].strip.empty?
    user.content
  else
    user[:name]
  end
end

# @param document [Nokogiri::XML::Document]
# @param url [String]
def atom_feed_from(document, url)
  RSS::Maker.make('atom') do |maker|
    maker.channel.updated = Time.parse(document.at_xpath('bugzilla/bug/delta_ts').content)
    maker.channel.title = document.at_xpath('bugzilla/bug/short_desc').content
    maker.channel.id = url
    maker.channel.author = get_name(document.at_xpath('bugzilla/bug/reporter'))
    maker.channel.links.new_link do |l|
      l.href = url
      l.type = 'text/html'
      l.rel = :alternative
    end

    document.xpath('bugzilla/bug/long_desc').each do |desc|
      maker.items.new_item do |item|
        id = desc.at_xpath('commentid').content.to_i

        item.title = "comment ##{id}"
        item.id = "#{url}##{id}"
        item.author = get_name(desc.at_xpath('who'))
        item.updated = Time.parse(desc.at_xpath('bug_when').content)
        item.content.content = desc.at_xpath('thetext').content
        item.content.type = :text
      end
    end
  end
end

get '/' do
  send_file File.expand_path('index.html', settings.public_folder)
end

class BadURL < StandardError
end

def reject_request
  content_type 'text/plain'
  halt 400, 'The URL doesn’t seem to be a Bugzilla bug URL.'
end

get '/feed' do
  content_type :atom, charset: 'utf-8'

  uri = URI.parse(params[:url])
  reject_request if uri.query.nil?
  query = URI.decode_www_form(uri.query)
  query << [:ctype, :xml]
  uri.query = URI.encode_www_form(query)
  document = nil
  begin
    document = uri.open { |f| Nokogiri::XML(f) }
  rescue SocketError, OpenURI::HTTPError
    reject_request
  end
  reject_request unless document.errors.empty?

  atom_feed_from(document, params[:url]).to_s
end
