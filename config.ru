require 'appengine-rack'
require 'dm-core'
require 'meh_payment_processor'
require 'appengine-apis/labs/taskqueue'
require 'appengine-apis/urlfetch'
require 'appengine-apis/users'

AppEngine::Rack.configure_app(
  :application => 'meh-payment-processor',
  :version => '0-0-1'
)

# Configure DataMapper to use the App Engine datastore
DataMapper.setup(:default, "appengine://auto")

# Exclude test files
AppEngine::Rack.app.resource_files.exclude %w(/features/** /spec/**)

# Include favicon
AppEngine::Rack.app.static_files.include %w(/public/favicon.ico)

if(methods.member?("to_xml"))
  map '/tasks' do
    use AppEngine::Rack::AdminRequired
  end

  map '/admin' do
    use AppEngine::Rack::AdminRequired
  end

  map '/cron' do
    use AppEngine::Rack::AdminRequired
  end
end

run MehPaymentProcessor

