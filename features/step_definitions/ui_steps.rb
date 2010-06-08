Given /^I am logged in$/ do
end

When /^I follow "([^\"]*)" for that payee$/ do |link|
  When %{I follow "#{link}" within "//tr[@id='#{Payee.last.id}']"}
end
