require 'sinatra/base'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-observer'
require 'dm-types'
require './lib/dm_extlib_hash'
require './app/models/payment_request'
require './app/models/supplier'
require './app/models/payment_request_observer'

class MehPaymentProcessor < Sinatra::Base

  set app_settings = YAML.load(
    File.read('config/app_settings.yml')
  )[environment.to_s]

  # All uri's starting with /task are private for the
  # task queue. NOTE: never use create! with DM because
  # it will bypass hooks and the observer will not be run
  post '/tasks/payment_requests' do
    PaymentRequest.create(:external_id => params.delete("external_id"), :params => params)
  end
  
  put '/tasks/verify_payment_request/:id' do
    payment_request = PaymentRequest.get(params[:id])
    uri = URI.join(
      app_settings['requester_application_uri'],
      "payment_request/#{payment_request.external_id}"
    )
    uri.query = payment_request.params.to_params
    uri.scheme = app_settings['http_scheme'] # force HTTPS
    uri = uri.to_s
    response = AppEngine::URLFetch.fetch(uri, :method => 'HEAD')
    payment_request.update(:verified_at => Time.now) if response.code == "200"
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
  end
end
