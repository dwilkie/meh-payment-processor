class PaymentRequest
  include DataMapper::Resource
  property :id, Serial
  property :to, String, :format => :email_address, :required => true
  property :params, Yaml
  property :verified_at, DateTime
  timestamps :at
end
