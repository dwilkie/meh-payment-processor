require 'spec_helper'
describe "/admin/payees/index" do
  
  before{
    assigns[:payees] = [
      mock(
        "Payee",
        :id => 124221,
        :name => "John",
        :email => "johnny@gmail.com",
        :maximum_amount => mock(
          "Money",
          :format => "500",
          :currency => mock("Currency", :iso_code => "THB")
        )
      )
    ]
  }
  
  it "should render a link to add a new payee" do
    render
    response.should have_tag("a[href='/admin/payees/new']", "Add New")
  end
end

