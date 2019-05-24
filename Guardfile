# frozen_string_literal: true

guard :rack do
  watch('Gemfile.lock')
  watch('app.rb')
end

guard :rspec, cmd: 'rspec' do
  watch('Gemfile.lock')
  watch('app.rb')
  watch(%r{^spec/.+_spec\.rb})
end
