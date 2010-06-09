require 'securerandom'
module ApplicationHelper
  include ::Rack::Utils
  alias_method :h, :escape_html
  
  # http://gist.github.com/119874
  def partial(template, *args)
    template_array = template.to_s.split('/')
    template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(:layout => false)
    if collection = options.delete(:collection) then
      collection.inject([]) do |buffer, member|
        buffer << haml(:"#{template}", options.merge(:layout =>
        false, :locals => {template_array[-1].to_sym => member}))
      end.join("\n")
    else
      haml(:"#{template}", options)
    end
  end
  
  def form_authenticity_param
    "authenticity_token"
  end

  def form_authenticity_token
    session[:csrf_token] ||= SecureRandom.base64(32)
  end
  
  def protect_from_forgery(params)
    raise("Invalid Authenticity Token") unless form_authenticity_token == params.delete(form_authenticity_param)
  end
    
  def skip_forgery_protection?(request)
    skip = false
    settings.skip_forgery_protection.each do |path|
      if path.is_a?(String)
        skip = path == request
      elsif path.is_a?(Regexp)
        skip = path =~ request
      end
      break if skip
    end
    skip
  end
end
