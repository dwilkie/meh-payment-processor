require 'appengine-rack'
require 'dm-core'
require 'appengine-apis/labs/taskqueue'
require 'meh_payment_processor'

AppEngine::Rack.configure_app(
  :application => 'meh-payment-processor',
  #:precompilation_enabled => true,
  :version => '0-0-1')

# Configure DataMapper to use the App Engine datastore
DataMapper.setup(:default, "appengine://auto")

# Exclude test files
AppEngine::Rack.app.resource_files.exclude %w(features/** spec/**)

if(methods.member?("to_xml"))
  map '/tasks' do
    use AppEngine::Rack::AdminRequired
  end
end

run MehPaymentProcessor
