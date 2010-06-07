require 'spec_helper'
describe "/admin/payees/new" do
  it "should render the form partial" do
    self.should_receive(:partial).with(:'admin/payees/form')
    render
  end
end
