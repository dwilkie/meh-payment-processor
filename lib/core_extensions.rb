module CoreExtensions
  require 'addressable/uri'
  module Hash
    def to_query
      uri = Addressable::URI.new
      uri.query_values = self.stringify
      uri.query.gsub("[", "%5B").gsub("]", "%5D")
    end

    def stringify
      Marshal.load(Marshal.dump(self)).stringify!
    end

    # Destructively convert all keys and values to strings
    def stringify!
      keys.each do |key|
        new_key = key.to_s
        self[new_key] = delete(key)
        if self[new_key].is_a?(Hash)
          self[new_key].stringify!
        else
          self[new_key] = delete(new_key).to_s
        end
      end
      self
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

