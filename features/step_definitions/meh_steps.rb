Given /^a payment request exists(?: (.+))?$/ do |fields|
  fields = parse_fields(fields)
  PaymentRequest.create(:to => fields["to"], :params => fields)
end

When /^a payment is requested(?: (.+))?$/ do |fields|
  post "/payment_requests/create", parse_fields(fields)
end

Then(/^a payment request should exist(?: with (.+))?$/) do |fields|
  find_model!("payment_request", fields)
end

Then /^the payment request should have the following parameters: (.+)$/ do |params|
  payment_request = PaymentRequest.last
  payment_request.params.should == parse_fields(params)
end

Then /a verification request should be made to the requester application(?: with (.+))?$/ do |fields|
  fields = parse_fields(fields)
  fields.to_params
  AppEngine::URLFetch.last_request_uri.should == "http://localhost:3000/payment_requests/show?#{fields.to_params}"
end
