require 'rack/test'
module AppEngine
  class URLFetch
    cattr_accessor :responses
   
    def self.clean_registry
      self.responses = {}
    end
    
    def self.fetch(url, options={})
      options[:method] ||= 'GET'
      uri = URI.parse(url)
      self.responses ||= {}
      
      http_server =  Net::HTTP.new(uri.host, uri.port)
      http_server.use_ssl = (uri.port == 443)

      case options[:method]

      when 'HEAD'
        self.responses[url] = http_server.start do |http|
          http.head(uri.request_uri)
        end
      
      when 'POST'
        self.responses[url] = http_server.start do |http|
          http.post(uri.request_uri, options[:payload], options[:headers])
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
