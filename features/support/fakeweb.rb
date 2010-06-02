require 'fakeweb'

Before do
  FakeWeb.register_uri(
    :post,    URI.join("http://example.com", "payment_requests/create").to_s,
    :status => ["200", "OK"]
  )
end
