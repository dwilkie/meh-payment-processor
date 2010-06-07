require 'spec_helper'
describe "/admin/payees/index" do
  it "should render a link to add a new payee" do
    render
    response.should have_tag("a[href='/admin/payees/new']", "Add New")
  end
end

