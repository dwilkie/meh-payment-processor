Given /^a payment request exists(?: (.+))?$/ do |fields|
  fields = parse_fields(fields)
  PaymentRequest.create(:to => fields["to"], :params => fields)
end

When /^a payment request is received(?: with (.+))?$/ do |fields|
  post "/payment_requests/create", parse_fields(fields)
end

When /^the configured external application makes a payment request(?: with (.+))?$/ do |fields|
  FakeWeb.register_uri(
    :head, %r|http://localhost:3000/payment_requests/show\?[^\s\?]+|,
    :status => ["200", "OK"]
  )
  post "/payment_requests/create", parse_fields(fields)
end

Then(/^a payment request should (?:be created|exist)(?: with (.+))?$/) do |fields|
  @payment_request = PaymentRequest.last
end

Then /^the payment request should (not )?be (\w+)$/ do |negative, predicate|
  @payment_request ||=PaymentRequest.last
  unless negative
    @payment_request.send("#{predicate}?").should_not == false
  else
    @payment_request.send("#{predicate}?").should == false
  end
end

Then /^the payment request should have the following parameters: (.+)$/ do |params|
  payment_request = PaymentRequest.last
  payment_request.params.should == parse_fields(params)
end

Then /a verification request should be made to the configured external application(?: with (.+))?$/ do |fields|
  fields = parse_fields(fields)
  fields.to_params
  AppEngine::URLFetch.last_request_uri.should == "https://localhost:3000/payment_requests/show?#{fields.to_params}"
end
