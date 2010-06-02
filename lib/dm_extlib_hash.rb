class Hash
  class << self
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
