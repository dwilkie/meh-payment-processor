Given /^I have configured my app correctly for paypal$/ do
  register_paypal_payment_request
end

When /^a payment request is received(?: with (.+))?$/ do |fields|
  register_external_payment_request_uri(:head, ["404", "Not Found"])
  post "/payment_requests", parse_fields(fields)
end

When /^the configured external application makes a payment request(?: with (.+))?$/ do |fields|
  register_external_payment_request_uri(:head, ["200", "OK"])
  register_external_payment_request_uri(:put, ["200", "OK"])
  post "/payment_requests", parse_fields(fields)
end

Then(/^a (\w+) should (?:be created|exist)(?: with (.+))?$/) do |model_name, fields|
  model_instance = find_model!(model_name, fields)
end

Then /^the payment request should (not )?be (\w+)$/ do |negative, predicate|
  payment_request = PaymentRequest.last
  negative ||= ""
  negative = "_not" unless negative.blank?
  payment_request.send("should#{negative}", send("be_#{predicate}"))
end

Then /^a HEAD request should have been made to the external application for the payment request: (\d+) returning status "([^\"]*)"(?: with (.+))?$/ do |id, status, fields|
  fields = parse_fields(fields)
  response = AppEngine::URLFetch.responses["HEAD #{external_payment_request_uri(id, fields)}"]
  response.should_not be_nil
  "#{response.code} #{response.message}".should == status
end

Then /^a PUT request should have been made to the external application for the payment request: (\d+) returning status "([^\"]*)" containing the paypal response$/ do |id, status|
  AppEngine::URLFetch.responses.should include(
    "PUT #{external_payment_request_uri(id)}"
  )
end

Then /^a POST request should have been made to my paypal account returning status "([^\"]*)" containing the payment details$/ do |status|
  AppEngine::URLFetch.responses.should include("POST #{paypal_payments_uri}")
end
