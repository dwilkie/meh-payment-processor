module FakeWebHelper
  def register_payment_request_callback_uri(status)
    FakeWeb.register_uri(
      :head, %r|http://localhost:3000/payment_request/\d+\?[^\s\?]+|,
      :status => status
    )
  end
  
  def payment_request_callback_uri(id, fields)
    "http://localhost:3000/payment_request/#{id}?#{fields.to_params}"
  end
end
