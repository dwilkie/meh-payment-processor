Given /^a payment request exists(?: (.+))?$/ do |fields|
  fields = parse_fields(fields)
  PaymentRequest.create(:to => fields["to"], :params => fields)
end

When /^a payment is requested(?: (.+))?$/ do |fields|
  post "/tasks/payment_requests/create", parse_fields(fields)
end

Then(/^a payment request should exist(?: with (.+))?$/) do |fields|
  find_model!("payment_request", fields)
end

Then /^the payment request should have the following parameters: (.+)$/ do |params|
  payment_request = PaymentRequest.last
  payment_request.params.should == parse_fields(params)
end
