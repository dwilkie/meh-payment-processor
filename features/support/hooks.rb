Before('@create_payment_request') do
  FakeWeb.register_uri(
    :head, %r|^http://localhost:3000/payment_requests/show\?[^\s\?]+$|,
    :status => ["404", "Not Found"]
  )
end
After do
  FakeWeb.clean_registry
end
