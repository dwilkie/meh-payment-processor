class PaymentRequestObserver
  include DataMapper::Observer
  observe PaymentRequest
  
  after :create do
    params = {"id" => self.id, "params" => self.params}
    AppEngine::Labs::TaskQueue.add(
      nil,
      :params => {"params" => params.inspect},
      :url => '/tasks/requester_application/payment_requests/show'
    )
  end
end
