class PaymentNotification
  def initialize(external_application_uri)
    @external_application_uri = external_application_uri
  end
  
  def notify(external_id, payment_response)
    uri = URI.join(
      @external_application_uri,
      "payment_request/#{external_id}"
    )
    @raw_response = AppEngine::URLFetch.fetch(
      uri.to_s,
      :payload => payment_response,
      :method => 'PUT'
    )
  end
end
