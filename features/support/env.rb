app_file = File.join(File.dirname(__FILE__), *%w[.. .. meh_payment_processor])
require app_file
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = app_file

require 'capybara'
require 'capybara/cucumber'
require 'rspec/expectations'
require 'rack/test'
require 'dm-core'
require 'dm-migrations'
require 'dm-transactions'
require 'fakeweb'
require 'ruby-debug'
require 'database_cleaner'
require 'database_cleaner/cucumber'

Capybara.app = MehPaymentProcessor
FakeWeb.allow_net_connect = false
DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!
DatabaseCleaner.strategy = :transaction

class MyWorld
  require File.join(File.dirname(__FILE__), './pickle')
  require File.join(File.dirname(__FILE__), './fakeweb_helper')
  include Pickle
  include FakeWebHelper
  include Rack::Test::Methods
  include Rspec::Matchers

  def app
    MehPaymentProcessor.set :environment, :test
  end
end

World{MyWorld.new}

