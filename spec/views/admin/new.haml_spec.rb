require 'spec_helper'
describe "/admin/payees/new" do
  it "should render a form" do
    render
    response.should have_tag("form[action='/admin/payees'][method='POST']")
  end
end
