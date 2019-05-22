# frozen_string_literal: true

require 'rss'

require_relative '../app'

RSpec.describe 'The application' do
  it 'works' do
    get '/feed', url: 'https://bugzilla.mozilla.org/show_bug.cgi?id=256718'
    expect(last_response).to be_ok
    rss = RSS::Parser.parse(last_response.body)
    expect(rss.title.content).to eq('Implement Atom feeds for bugs')
  end
end
