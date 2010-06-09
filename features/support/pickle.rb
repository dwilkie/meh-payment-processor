# Shamelessly copied from ianwhite/pickle
# http://github.com/ianwhite/pickle.git
require 'active_support/inflector/inflections'
require 'active_support/inflector/methods'
module Pickle
  include ActiveSupport::Inflector
  # given a string like 'foo: "bar", bar: "baz"'
  # returns {"foo" => "bar", "bar" => "baz"}
  def parse_fields(fields)
    if fields.blank?
      {}
    elsif fields =~ /^#{match_fields}$/
      fields.scan(/(#{match_field})(?:,|$)/).inject({}) do |m, match|
        m.merge(parse_field(match[0]))
      end
    else
      raise ArgumentError, "The fields string is not in the correct format.\n\n'#{fields}' did not match: #{match_fields}"
    end
  end

  # given a string like 'foo: expr' returns {key => value}
  def parse_field(field)
    if field =~ /^#{capture_key_and_value_in_field}$/
      { $1 => eval($2) }
    else
      raise ArgumentError, "The field argument is not in the correct format.\n\n'#{field}' did not match: #{match_field}"
    end
  end

  def find_model(a_model_name, fields = nil)
    model_class = ActiveSupport::Inflector.inflections do |inflect|
      constantize(classify(a_model_name))
    end
    fields = parse_fields(fields)
    model_class.first(fields)
  end

  def find_model!(a_model_name, fields = nil)
    find_model(a_model_name, fields) or raise "Can't find '#{a_model_name}' in this scenario"
  end

  def match_quoted
    '(?:[^\\"]|\\.)*'
  end

  def match_value
    "(?:\"#{match_quoted}\"|nil|true|false|[+-]?[0-9_]+(?:\\.\\d+)?)"
  end

  def match_field
    "(?:\\w+: #{match_value})"
  end

  def match_fields
    "(?:#{match_field}, )*#{match_field}"
  end

  def capture_key_and_value_in_field
    "(?:(\\w+): #{capture_value})"
  end

  # create capture analogues of match methods
  instance_methods.select{|m| m =~ /^match_/}.each do |method|
    eval <<-end_eval
      def #{method.to_s.sub('match_', 'capture_')}         # def capture_field
        "(" + #{method} + ")"                         #   "(" + match_field + ")"
      end                                             # end
    end_eval
  end
end

