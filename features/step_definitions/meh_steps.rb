Given /^I have configured my app correctly for paypal$/ do
  register_paypal_payment_request
end


When /^a payment request is received(?: with (.+))?$/ do |fields|
  register_payment_request_callback_uri(["404", "Not Found"])
  post "/payment_requests", parse_fields(fields)
end

When /^the configured external application makes a payment request(?: with (.+))?$/ do |fields|
  register_payment_request_callback_uri(["200", "OK"])
  post "/payment_requests", parse_fields(fields)
end

Then(/^a (\w+) should (?:be created|exist)(?: with (.+))?$/) do |model_name, fields|
  model_instance = find_model!(model_name, fields)
  model_instance.nil?.should_not == true
end

Then /^the payment request should (not )?be (\w+)$/ do |negative, predicate|
  payment_request = PaymentRequest.last
  negative ||= ""
  negative = "_not" unless negative.blank?
  payment_request.send("should#{negative}", send("be_#{predicate}"))
end

Then /^a verification request to the configured external application should return status "([^\"]*)" for (\d+)(?: with (.+))?$/ do |status, id, fields|
  fields = parse_fields(fields)
  response = AppEngine::URLFetch.responses[payment_request_callback_uri(id, fields)]
  response.should_not be_nil
  "#{response.code} #{response.message}".should == status
end

Then /^a payment request should be made to my configured paypal account$/ do
  AppEngine::URLFetch.responses.should include(paypal_payments_uri)
end
