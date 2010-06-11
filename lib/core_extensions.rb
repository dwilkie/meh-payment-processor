module CoreExtensions
  require 'addressable/uri'
  module Hash
    def to_query
      uri = Addressable::URI.new
      uri.query_values = self
      uri.query = Addressable::URI.normalize_component(uri.query)
      Addressable::URI.encode(uri.query)
    end
  end

  module String
    def from_query
      uri = Addressable::URI.new
      uri.query = self
      uri.query_values
    end
  end
end

class Hash
  include CoreExtensions::Hash
end

class String
  include CoreExtensions::String
end

