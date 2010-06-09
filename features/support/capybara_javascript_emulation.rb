# modified from original: http://github.com/aslakhellesoy/cucumber-rails/blob/master/lib/cucumber/rails/capybara_javascript_emulation.rb
module Cucumber
  module Rails
    module CapybaraJavascriptEmulation
      require File.join(File.dirname(__FILE__), '../../app/helpers/application_helper')
      include ApplicationHelper

      def self.included(base)
        base.class_eval do
          alias_method :click_without_javascript_emulation, :click
          alias_method :click, :click_with_javascript_emulation
        end
      end

      def click_with_javascript_emulation
        if link_with_non_get_http_method?
          Capybara::Driver::RackTest::Form.new(driver, js_form(self[:href], emulated_method)).submit(self)
        else
          click_without_javascript_emulation
        end
      end

      private

      def js_form(action, emulated_method, method = 'POST')
        js_form = node.document.create_element('form')
        js_form['action'] = action
        js_form['method'] = method
        
        csrf_field = node.document.create_element('input')
        csrf_field['type'] = 'hidden'
        csrf_field['name'] = form_authenticity_param
        # this is a hack....
        # if there is no current session this will fail
        csrf_field['value'] = driver.current_session.last_request.env["rack.session"][:csrf_token]
        js_form.add_child(csrf_field)

        if emulated_method and emulated_method.downcase != method.downcase
          input = node.document.create_element('input')
          input['type'] = 'hidden'
          input['name'] = '_method'
          input['value'] = emulated_method
          js_form.add_child(input)
        end
        
        js_form
      end

      def link_with_non_get_http_method?
        tag_name == 'a' && node['data-method'] && node['data-method'] =~ /(?:delete|put|post)/
      end

      def emulated_method
        node['data-method']
      end
    end
  end
end

class Capybara::Driver::RackTest::Node
  include Cucumber::Rails::CapybaraJavascriptEmulation
end

Before('~@no-js-emulation') do
  # Enable javascript emulation
  Capybara::Driver::RackTest::Node.class_eval do
    alias_method :click, :click_with_javascript_emulation
  end
end

Before('@no-js-emulation') do
  # Disable javascript emulation
  Capybara::Driver::RackTest::Node.class_eval do
    alias_method :click, :click_without_javascript_emulation
  end
end
