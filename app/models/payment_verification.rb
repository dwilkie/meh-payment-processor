class PaymentVerification
  
  def initialize(external_application_uri)
    @external_application_uri = external_application_uri
  end
  
  def verify(external_id, params)
    uri = URI.join(
      @external_application_uri,
      "payment_request/#{external_id}"
    )
    uri.query = params.to_params
    uri = uri.to_s
    @raw_response = AppEngine::URLFetch.fetch(uri, :method => 'HEAD')
    @raw_response.code == "200"
  end
end
