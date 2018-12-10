$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sr/jimson'

SPEC_URL = 'http://localhost:8999'

begin
  require 'simplecov'
  SimpleCov.start 'rails' if ENV['COVERAGE']
rescue LoadError
end
