require 'sinatra/base'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-observer'
require 'dm-types'
require './app/models/payment_request'
require './app/models/payment_request_observer'

class MehPaymentProcessor < Sinatra::Base

  set app_settings = YAML.load(
    File.read('config/app_settings.yml')
  )[environment.to_s]

  get '/' do
    "maggot"
  end
  
  post '/tasks/payment_requests/create' do
    PaymentRequest.create(:email => params[:email], :params => params)
  end
  
  put '/tasks/payment_requests/update' do
    AppEngine::URLFetch.fetch(
      app_settings['meh_payment_request_url'], :method => 'PUT'
    )
  end

  post '/payment_requests/create' do
    # Schedule the creation of a payment request to the queue
    AppEngine::Labs::TaskQueue.add(
      nil,
      :params => params,
      :url => '/tasks/payment_requests/create'
    )
    redirect '/'
  end
  
  private

end
