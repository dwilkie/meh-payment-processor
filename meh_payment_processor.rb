require 'sinatra/base'
require 'dm-core'
require 'dm-timestamps'
require './app/models/payment_request'

class MehPaymentProcessor < Sinatra::Base

  get '/' do
    "maggot"
  end
  
  post '/tasks/payment_requests/create' do
    PaymentRequest.create(:email => params[:email])
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
end
