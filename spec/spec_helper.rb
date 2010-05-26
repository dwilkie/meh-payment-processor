require File.join(File.dirname(__FILE__), '..', 'meh_payment_processor')

require 'sinatra'
require 'rack/test'
require 'rspec'
require 'rspec/autorun'

Rspec.configure do |c|
  c.color_enabled = true
end

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
