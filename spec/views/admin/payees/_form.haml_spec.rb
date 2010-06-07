require 'spec_helper'
describe "/admin/payees/_form" do
  it "should render the form" do
    render
    response.should have_tag("form[action='/admin/payees'][method='POST']")
  end
end
