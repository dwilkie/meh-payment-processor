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
  unless negative
    payment_request.send("#{predicate}?").should_not == false
  else
    payment_request.send("#{predicate}?").should == false
  end
end

Then /^a verification request should be made to the configured external application for (\d+)(?: with (.+))?$/ do |id, fields|
  fields = parse_fields(fields)
  AppEngine::URLFetch.last_request_uri.should == payment_request_callback_uri(id, fields)
end

Then /^the response should be status "([^\"]*)"$/ do |response_status|
  last_response = AppEngine::URLFetch.last_response
  "#{last_response.code} #{last_response.message}".should == response_status
end
