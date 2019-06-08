# frozen_string_literal: true

require 'rss'

require_relative '../app'

RSpec.describe 'The application' do
  context 'with correct Bugzilla link' do
    before(:example) do
      get '/feed', url: 'https://bugzilla.mozilla.org/show_bug.cgi?id=256718'
    end

    it 'returns OK' do
      expect(last_response).to be_ok
    end

    it 'shows coorrect title' do
      rss = RSS::Parser.parse(last_response.body)
      expect(rss.title.content).to eq('Implement Atom feeds for bugs')
    end
  end

  it 'uses username when display name is not available' do
    get '/feed', url: 'https://bugzilla.mozilla.org/show_bug.cgi?id=1430473'
    expect(last_response).to be_ok
  end

  {
    'unknown domain' => 'http://invalid.example.com/show_bug.cgi?id=256718',
    'non-bug URL' => 'https://bugzilla.mozilla.org',
    'URL without HTTP OK response' => 'https://www.example.com/show_bug.cgi?id=256718',
    'non-Bugzilla response' => 'https://www.example.com/index.html?id=256718'
  }.each do |name, url|
    it "returns Bad Request for #{name}" do
      get '/feed', url: url
      expect(last_response).to be_bad_request
    end
  end
end
