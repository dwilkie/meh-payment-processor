When /^(?:|I )request a payment$/ do
  params = {
    "email"=>"meh@gmail.com"
  }
  post "/tasks/payment_requests/create", params
end

Then /^there should be a payment request$/ do
  PaymentRequest.all.count.should == 1
end
