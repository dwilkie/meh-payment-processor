app_file = File.join(File.dirname(__FILE__), *%w[.. .. meh_payment_processor])
require app_file
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = app_file

require 'rspec/expectations'
require 'rack/test'
require 'dm-core'
require 'fakeweb'
require 'httparty'
require 'ruby-debug'
require 'database_cleaner'
require 'database_cleaner/cucumber'

DatabaseCleaner.strategy = :transaction

FakeWeb.allow_net_connect = false
DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

class MyWorld
  require File.join(File.dirname(__FILE__), './pickle')
  require File.join(File.dirname(__FILE__), './fakeweb_helper')
  include Pickle
  include FakeWebHelper
  include Rack::Test::Methods
  
  def app
    MehPaymentProcessor.set :environment, :test
  end
end

World{MyWorld.new}
