require 'spec_helper'
describe "/admin/payees/edit" do
  it "should render the form partial" do
    self.should_receive(:partial).with(:'admin/payees/form')
    render
  end
end
