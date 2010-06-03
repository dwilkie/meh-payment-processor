Before('@create_payment_request') do
  FakeWeb.register_uri(
    :get, %r|http://localhost:3000/payment_requests/show\?[^\s]+|,
    :status => ["200", "OK"]
  )
end
