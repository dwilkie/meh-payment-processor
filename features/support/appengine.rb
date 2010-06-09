require 'rack/test'
module AppEngine
  class URLFetch
    cattr_accessor :requests

    def self.clean_registry
      self.requests = {}
    end

    def self.fetch(url, options={})
      options[:method] ||= 'GET'
      uri = URI.parse(url)
      self.requests ||= {}

      http_server =  Net::HTTP.new(uri.host, uri.port)
      http_server.use_ssl = (uri.port == 443)

      case options[:method]

      when 'HEAD'
        response = http_server.start do |http|
          http.head(uri.request_uri)
        end
        self.requests["HEAD #{url}"] = {:response => response.body}
        response

      when 'POST'
        response = http_server.start do |http|
          http.post(uri.request_uri, options[:payload], options[:headers])
        end
        self.requests["POST #{url}"] = {
          :payload => options[:payload],
          :response => response.body
        }
        response

      when 'PUT'
        response = http_server.start do |http|
          http.put(uri.request_uri, options[:payload], options[:headers])
        end
        self.requests["PUT #{url}"] = {
          :payload => options[:payload],
          :response => response.body
        }
        response
      end
    end
  end

  class Users
    def self.create_logout_url(url)
      '/logout'
    end
  end

  module Labs
    class TaskQueue
      def self.add(payload, options)
        task = Task.new
        options[:method] ||= 'POST'
        payload ||= options[:params]

        case options[:method]

        when 'POST'
          task.post options[:url], payload

        when 'PUT'
          task.put options[:url], payload
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

