class PaymentRequestObserver
  include DataMapper::Observer
  observe PaymentRequest

  # After it's created
  # Verify (update i.e. PUT) it
  after :create do
    AppEngine::Labs::TaskQueue.add(
      nil,
      :url => "/tasks/verify/payment_requests/#{self.id}",
      :method => 'PUT'
    )
  end

  # After it's verified check if its internally authenticated
  # then Process (update i.e. PUT) it, or notify the external app
  after :verify do
    unless authorization_errors = Payee.authorization_errors(self.payee_params)
      AppEngine::Labs::TaskQueue.add(
        nil,
        :url => "/tasks/process/payment_requests/#{self.id}",
        :method => 'PUT'
      )
    else
      self.internally_unauthorize
      AppEngine::Labs::TaskQueue.add(
        nil,
        :params => authorization_errors,
        :url => "/tasks/external_payment_requests/#{self.external_id}",
        :method => 'PUT'
      )
    end
  end

  # After it's completed
  # Update (i.e. PUT) the external payment request
  after :complete do
    AppEngine::Labs::TaskQueue.add(
      self.payment_response,
      :url => "/tasks/external_payment_requests/#{self.external_id}",
      :method => 'PUT'
    )
  end

end

