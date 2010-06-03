class PaymentRequestObserver
  include DataMapper::Observer
  observe PaymentRequest
  
  after :create do
    AppEngine::Labs::TaskQueue.add(
      nil,
      :params => {"id" => self.id.to_s},
      :url => '/tasks/requester_application/payment_requests/show'
    )
  end
end
