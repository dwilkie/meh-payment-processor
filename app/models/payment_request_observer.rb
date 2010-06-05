class PaymentRequestObserver
  include DataMapper::Observer
  observe PaymentRequest
  
  # After it's created
  # Verify (update i.e. PUT) it
  after :create do
    AppEngine::Labs::TaskQueue.add(
      nil,
      :url => "/tasks/verify/payment_request/#{self.id}",
      :method => 'PUT'
    )
  end
  
  # After it's verified
  # Process (update i.e. PUT) it
  after :verify do
    AppEngine::Labs::TaskQueue.add(
      nil,
      :url => "/tasks/process/payment_request/#{self.id}",
      :method => 'PUT'
    )
  end
  
  # After it's completed
  # Update (i.e. PUT) the external payment request
  after :complete do
    AppEngine::Labs::TaskQueue.add(
      self.payment_response,
      :url => "/tasks/external_payment_request/#{self.external_id}",
      :method => 'PUT'
    )
  end
end
