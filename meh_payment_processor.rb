require 'sinatra/base'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-observer'
require 'dm-types'
require './lib/dm_extlib_hash'
require './app/models/payment_request'
require './app/models/payment_request_observer'
require './app/models/external_payment_request'
require './app/models/paypal_payment_request'

class MehPaymentProcessor < Sinatra::Base

  set app_settings = YAML.load(
    File.read("config/#{environment.to_s}.yml")
  )

  # All uri's starting with /task are private for the
  # task queue. NOTE: never use create! with DM because
  # it will bypass hooks and the observer will not be run
  post '/tasks/payment_requests' do
    PaymentRequest.create(
      :external_id => params.delete("external_id"),
      :params => params
    )
    200
  end
  
  put '/tasks/verify/payment_request/:id' do
    payment_request = PaymentRequest.get(params[:id])
    external_payment_request = ExternalPaymentRequest.new(
      app_settings['external_application']['uri']
    )
    if external_payment_request.verified?(
      payment_request.external_id,
      payment_request.params
    )
      payment_request.verify
    end
    200
  end

  put '/tasks/process/payment_request/:id' do
    payment_request = PaymentRequest.get(params[:id])
    paypal_payment_request = PaypalPaymentRequest.new(
      app_settings['paypal']['api_credentials']
    )
    response = paypal_payment_request.pay(
      app_settings['paypal']['uri'],
      app_settings['my_application']['uri'],
      app_settings['my_application']['uri'],
      payment_request.params
    )
    payment_request.complete(response)
    200
  end
  
  put '/tasks/external_payment_request/:id' do
    ExternalPaymentRequest.new(
      app_settings['external_application']['uri']
    ).notify(params[:id], request.env["rack.input"].read)
  end

  # External request is executed here
  # We just delegate the work to /tasks/payment_requests/create
  # for a later time to ensure a fast response time
  post '/payment_requests' do
    # Schedule the creation of a payment request to the queue
    AppEngine::Labs::TaskQueue.add(
      nil,
      :params => params,
      :url => '/tasks/payment_requests'
    )
    200
  end
end
