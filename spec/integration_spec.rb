# frozen_string_literal: true

require 'rss'

require 'rack/test'
require 'rspec'
require 'pry-byebug'

ENV['RACK_ENV'] = 'test'

require_relative '../app'

module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

RSpec.configure { |c| c.include RSpecMixin }

describe 'The application' do
  it 'works' do
    get '/feed', url: 'https://bugzilla.mozilla.org/show_bug.cgi?id=256718'
    expect(last_response).to be_ok
    rss = RSS::Parser.parse(last_response.body)
    expect(rss.title.content).to eq('Implement Atom feeds for bugs')
  end
end
