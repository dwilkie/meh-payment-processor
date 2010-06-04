require 'rack/test'
module AppEngine
  class URLFetch
    cattr_accessor :last_request_uri, :last_response
    
    def self.clean_registry
      self.last_request_uri = nil
      self.last_response = nil
    end
    
    def self.fetch(url, options={})
      @@last_request_uri = url
      options[:method] ||= 'GET'
      uri = URI.parse(url)
      
      case options[:method]
      
      when 'HEAD'
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          @@last_response = http.head(uri.request_uri)
        end
      end
    end
  end
  
  module Labs
    class TaskQueue
      def self.add(payload, options)
        task = Task.new
        options[:method] ||= 'POST'
        
        case options[:method]
        
        when 'POST'
          task.post options[:url], options[:params]
        
        when 'PUT'
          task.put options[:url], options[:params]
        end
        
        env = task.last_request.env
        error = env["sinatra.error"].to_s
        unless error.blank?
          error << " in " << env["PATH_INFO"]
          raise Exception, error
        end
      end
    end
    class Task
      include Rack::Test::Methods
      def app
        MehPaymentProcessor
      end
    end
  end
end
