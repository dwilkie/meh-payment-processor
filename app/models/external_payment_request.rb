# Represents a PaymentRequest resource on the external application
class ExternalPaymentRequest
  def initialize(external_application_uri)
    @external_application_uri = external_application_uri
  end

  def verified?(id, params)
    uri = URI.join(
      @external_application_uri,
      "payment_requests/#{id}"
    )
    uri.query = params.to_params
    uri = uri.to_s
    @raw_response = AppEngine::URLFetch.fetch(uri, :method => 'HEAD')
    @raw_response.code == "200"
  end

  def notify(id, payment_response)
    uri = URI.join(
      @external_application_uri,
      "payment_requests/#{id}"
    )
    @raw_response = AppEngine::URLFetch.fetch(
      uri.to_s,
      :payload => payment_response,
      :method => 'PUT'
    )
    @raw_response.code
  end
end
