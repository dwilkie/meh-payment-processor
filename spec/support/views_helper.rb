# Modified from original blog: 
# http://japhr.blogspot.com/2009/03/rspec-with-sinatra-haml.html

require 'haml'
require 'rspec_tag_matchers'

VIEWS_PATH = File.join(File.dirname(__FILE__), '..', '..', 'app', 'views')

Rspec.configure do |c|
  c.include(RspecTagMatchers)
end

# Renders the template with Haml::Engine and assigns the
# @response instance variable
def render
  template = File.join(
    VIEWS_PATH, running_example.example_group.top_level_description
  )
  template = File.read("#{template}.haml")
  engine = Haml::Engine.new(template)
  @response = engine.render(Object.new, assigns_for_template)
end

# Convenience method to access the @response instance variable set in
# the render call
def response
  @response
end

# Sets the local variables that will be accessible in the HAML
# template
def assigns
  @assigns ||= { }
end

# Prepends the assigns keywords with an "@" so that they will be
# instance variables when the template is rendered.
def assigns_for_template
  assigns.inject({}) do |memo, kv|
    memo["@#{kv[0].to_s}".to_sym] = kv[1]
    memo
  end
end
