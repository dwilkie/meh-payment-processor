# Represents a PaymentRequest on the Paypal side
class PaypalPaymentRequest

  REQUEST_DATA_FORMAT = "NV"
  RESPONSE_DATA_FORMAT = "NV"

  attr_reader :response
  attr_reader :raw_response

  def initialize(api_credentials)
    @username = api_credentials['api_username']
    @password = api_credentials['api_password']
    @signature = api_credentials['signature']
    @app_id = api_credentials['application_id']
    raise(ArgumentError,
      "Missing Paypal credentials api_username: #{@username}, api_password: #{@api_password}, signature: #{@signature}, application_id: #{@app_id}"
    ) unless @username && @password && @signature && @app_id
  end

  def pay(uri, cancel_url, return_url, params)
    uri = URI.join(uri, "AdaptivePayments/Pay")

    request_body = body('PAY')
    request_body.merge!(
      {
        "feesPayer" => 'SENDER',
        "cancelUrl" => cancel_url,
        "returnUrl" => return_url
      }
    )

    request_body.merge!(params)
    request_body = stringify_body(request_body)

    @raw_response = AppEngine::URLFetch.fetch(
      uri.to_s,
      :method => 'POST',
      :payload => request_body,
      :headers => headers
    )
    @response = @raw_response.body
  end

  private
    def headers
      {
        "X-PAYPAL-SECURITY-USERID" => @username,
        "X-PAYPAL-SECURITY-PASSWORD" => @password,
        "X-PAYPAL-SECURITY-SIGNATURE" => @signature,
        "X-PAYPAL-REQUEST-DATA-FORMAT" => REQUEST_DATA_FORMAT,
        "X-PAYPAL-RESPONSE-DATA-FORMAT" => RESPONSE_DATA_FORMAT,
        "X-PAYPAL-APPLICATION-ID" => @app_id
       }
    end
    
    def body(action)
      {
        "requestEnvelope.errorLanguage" => "en_US",
        "actionType" => action
      }
    end
    
    def stringify_body(body)
      req = Net::HTTP::Post.new("/some_path")
      req.set_form_data(body)
      req.body
    end
end
