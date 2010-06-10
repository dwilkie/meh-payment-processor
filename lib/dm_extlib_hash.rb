# modified from
# http://github.com/datamapper/extlib/blob/master/lib/extlib/hash.rb
module CoreExtensions
  module Hash
    require 'uri'
    require 'net/http'
    ##
    # Convert to URL query param string
    #
    #   { :name => "Bob",
    #     :address => {
    #       :street => '111 Ruby Ave.',
    #       :city => 'Ruby Central',
    #       :phones => ['111-111-1111', '222-222-2222']
    #     }
    #   }.to_params
    #     #=> "name=Bob&address[city]=Ruby Central&address[phones][]=111-111-1111&address[phones][]=222-222-2222&address[street]=111 Ruby Ave."
    #
    # @return [String] This hash as a query string
    #
    # @api public
    def to_params
      params = self.map { |k,v| normalize_param(k,v) }.join
      params.chop! # trailing &
      params
    end

    ##
    # Convert to body string for PUT or POST request
    #
    #   hash = { :name => "Bob",
    #     :address => {
    #       :street => '111 Ruby Ave.',
    #       :city => 'Ruby Central',
    #       :phones => ['111-111-1111', '222-222-2222']
    #     }
    #   }.to_body
    #     #=> "name=Bob&address=%5b%3astreet%2c%20%22111%20Ruby%20Ave.%22%5d&address=%5b%3acity%2c%20%22Ruby%20Central%22%5d&address=%5b%3aphones%2c%20%5b%22111-111-1111%22%2c%20%22222-222-2222%22%5d%5d"
    #     CGI.unescape(hash)
    #       #=> "name=Bob&address=[:street, "111 Ruby Ave."]&address=[:city, "Ruby Central"]&address=[:phones, ["111-111-1111", "222-222-2222"]]"
    #
    # Note: Escape characters \" omitted for brevity
    #
    # @return [String] This hash as a body string
    #
    # @api public
    def to_body
      req = Net::HTTP::Post.new("/some_path")
      req.set_form_data(self)
      req.body
    end

    ##
    # Convert a key, value pair into a URL query param string
    #
    #   normalize_param(:name, "Bob")   #=> "name=Bob&"
    #
    # @param [Object] key The key for the param.
    # @param [Object] value The value for the param.
    #
    # @return [String] This key value pair as a param
    #
    # @api public
    URI_ENCODE_PATTERN = Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")
    def normalize_param(key, value)
      param = ''
      stack = []

      if value.is_a?(Array)
        param << value.map { |element| normalize_param("#{key}[]", element) }.join
      elsif value.is_a?(Hash)
        stack << [key,value]
      else
        param << [key,value].map {|v| URI.encode(v.to_s, URI_ENCODE_PATTERN)}.join('=') + '&'
      end

      stack.each do |parent, hash|
        hash.each do |k, v|
          if v.is_a?(Hash)
            stack << ["#{parent}[#{k}]", v]
          else
            param << normalize_param("#{parent}[#{k}]", v)
          end
        end
      end

      param
    end
  end
end

class Hash
  include CoreExtensions::Hash
end

