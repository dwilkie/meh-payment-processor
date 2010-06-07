require 'spec_helper'
describe "home" do
  it "should display a link to the payees page" do
    render
    response.should have_tag("a[href='admin/payees']", "Configure Payees")
  end
end
