Given /^an? (remotely unauthorized |internally unauthorized |verified |processing |completed )?payment request exists(?: with )?(?:id: (\d+))?(?:, (.+))?$/ do |status, id, fields|
  register_remote_payment_request(:head, ["200", "OK"])
  register_paypal_payment_request
  register_remote_payment_request(:put, ["200", "OK"])
  payment_request = PaymentRequest.new(
    "id" => "12345",
    "payee" => {"email" => "m@g.com", "amount" => "5", "currency" => "THB"},
    "payment" => {"details" => "something"}
  )
  payment_request.id = id.to_i if id
  payment_request.save
  payment_request.update(parse_fields(fields)) if fields
  unless status =~ /^completed/
    payment_request = PaymentRequest.get(id)
    unless status =~ /^processing/
      unless status =~ /^verified/
        if status =~ /^internally unauthorized/
          payment_request.internally_unauthorize("some_error" => true)
        elsif status =~ /^remotely unauthorized/
          payment_request.remotely_unauthorize
        end
        payment_request.verified_at = nil
      end
      payment_request.sent_for_processing_at = nil
    end
    payment_request.completed_at = nil
    payment_request.save
  end
end

Given /^a payee exists(?: with (.+))?$/ do |fields|
  Payee.create(parse_fields(fields))
end

Given /^the response (?:is|was) "(?:[^\"]*)"$/ do
   # this step is intentionally empty!
end

Given /^I have not configured any payees$/ do
  # this step is intentionally empty!
end

When /^a payment request is received with: "([^\"]*)"$/ do |fields|
  register_remote_payment_request(:head, ["404", "Not Found"])
  post "/payment_requests", instance_eval(fields)
end

When /^another payment request is received with: "([^\"]*)"$/ do |fields|
  FakeWeb.clean_registry
  post "/payment_requests", instance_eval(fields)
end

When /^the configured remote application makes a payment request with: "([^\"]*)"$/ do |fields|
  register_remote_payment_request(:head, ["200", "OK"])
  register_paypal_payment_request
  register_remote_payment_request(:put, ["200", "OK"])
  post "/payment_requests", instance_eval(fields)
end

When /^a payment notification verification request is received for (\d+)(?: with: "([^\"]*)")?$/ do |id, fields|
  fields = instance_eval(fields) if fields
  @response = head "/payment_requests/#{id}", fields
end

When /^I am CSRF attacked to trigger the process payment request task for the payment request: (\d+)$/ do |id|
  AppEngine::URLFetch.clean_registry
  put "/tasks/process/payment_requests/#{id}"
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

Then /^a HEAD request should have been made to the remote application for the payment request: (\d+), with the query string containing: "([^\"]*)"$/ do |id, fields|
  fields = instance_eval(fields)
  request = AppEngine::URLFetch.requests["HEAD #{remote_payment_request_uri(id, fields)}"]
  request.should_not be_nil
end

Then /^a PUT request should have been made to the remote application for the payment request: (\d+), containing: (?:the paypal response|"([^\"]*)")$/ do |id, payload|
  payment_request = find_model!("payment_request")
  request_key = "PUT #{remote_payment_request_uri(id)}"
  AppEngine::URLFetch.requests.should include(request_key)
  request_payload = AppEngine::URLFetch.requests[request_key][:payload]
  unless payload
    payload = paypal_response_payload(
      AppEngine::URLFetch.requests["POST #{paypal_payments_uri}"][:response]
    )
  else
    payload = internal_errors_payload(instance_eval(payload).to_query)
  end
  request_payload.should == notification_payload(payment_request.id, payload)
end

Then /^a POST request should (not )?have been made to my paypal account(?: containing: (.+))?$/ do |no_request, params|
  no_request ||= ""
  no_request = "_not" unless no_request.blank?
  request_key = "POST #{paypal_payments_uri}"
  AppEngine::URLFetch.requests.send("should#{no_request}", include(request_key))
  AppEngine::URLFetch.requests[request_key][:payload].should include(
    parse_fields(params).to_query) if no_request.blank?
end

Then /^the response should be (\d+)$/ do |response|
   @response.status.should == response.to_i
end

Then /^(\d) payment requests? should exist$/ do |count|
  PaymentRequest.all.size.should == count.to_i
end

Then /^no outgoing requests should be made$/ do
  # this is intentionally empty!
end

