require 'spec_helper'

describe "/user_sessions/new" do
  let(:user_session) { mock_model(UserSession, :null_object => true).as_new_record }

  before(:each) do
    assigns[:user_session] = user_session
    user_session.errors.stub!(:[]).and_return(nil)
  end

  context "rendering the login form" do
    it "should display the title" do
      template.should_receive(:title).with(I18n.t('forms.user_session.title'))
      render
    end

    it "should render a form to create a new user session (log in the user)" do
      render
      response.should have_selector("form[method=post]", :action => user_sessions_path)
    end

    it "should render a label and text field for the users email" do
      render
      response.should have_selector("#user_session_email_input") do |input|
        input.should have_selector("label", :content => I18n.t('authlogic.attributes.user_session.email'))
        input.should have_selector("input", :name => "user_session[email]", :type => "text")
      end
    end

    it "should render a text field for the users password" do
      render
      response.should have_selector("#user_session_password_input") do |input|
        input.should have_selector("label", :content => I18n.t('authlogic.attributes.user_session.password'))
        input.should have_selector("input", :name => "user_session[password]", :type => "password")
      end
    end

    it "should render a button to login" do
      render
      response.should have_selector("#user_session_submit", :value => I18n.t('formtastic.actions.login'), :type => "submit")
    end
  end

  context "logging in" do
    context "unsuccessfully" do
      it "should show generalised login errors" do
        user_session.errors.should_receive(:[]).with(:base).and_return("some generalised error")
        render
        response.should have_selector("form") do |form|
          form.should have_selector("p", :content => "some generalised error")
        end
      end
    end
  end
end

