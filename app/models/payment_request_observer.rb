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
  # then Process (update i.e. PUT) it, or notify the remote app
  after :verify do
    unless authorization_errors = Payee.authorization_errors(self.payee_params)
      AppEngine::Labs::TaskQueue.add(
        nil,
        :url => "/tasks/process/payment_requests/#{self.id}",
        :method => 'PUT'
      )
    else
      self.internally_unauthorize(authorization_errors)
      AppEngine::Labs::TaskQueue.add(
        nil,
        :url => "/tasks/remote_payment_requests/#{self.id}",
        :method => 'PUT'
      )
    end
  end

  # After it's completed
  # Update (i.e. PUT) the remote payment request
  after :complete do
    AppEngine::Labs::TaskQueue.add(
      nil,
      :url => "/tasks/remote_payment_requests/#{self.id}",
      :method => 'PUT'
    )
  end

end

