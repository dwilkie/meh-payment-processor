app_file = File.join(File.dirname(__FILE__), *%w[.. .. meh_payment_processor])
require app_file
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = app_file

require 'rspec/expectations'
require 'rack/test'
require 'dm-core'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!

class MyWorld
  require File.join(File.dirname(__FILE__), './pickle')
  include Pickle
  include Rack::Test::Methods
  
  def app
    MehPaymentProcessor
  end
end

World{MyWorld.new}
