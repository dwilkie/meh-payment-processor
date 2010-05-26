class PaymentRequestObserver
  include DataMapper::Observer
  observe PaymentRequest
  
  after :create do
    puts self.params.inspect
    AppEngine::Labs::TaskQueue.add(
      nil,
      :params => self.params,
      :url => '/tasks/payment_requests/update'
    )
  end
end
