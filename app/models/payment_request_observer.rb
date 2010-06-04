class PaymentRequestObserver
  include DataMapper::Observer
  observe PaymentRequest
  
  after :create do
    AppEngine::Labs::TaskQueue.add(
      nil,
      :url => "/tasks/verify_payment_request/#{self.id}",
      :method => 'PUT'
    )
  end
end
