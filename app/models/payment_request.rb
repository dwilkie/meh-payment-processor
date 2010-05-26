class PaymentRequest
  include DataMapper::Resource
  property :id, Serial
  property :email, String
  timestamps :at
end
