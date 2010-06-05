class PaymentRequest
  include DataMapper::Resource
  property :id, Serial
  property :external_id, Integer, :required => true
  property :params, Yaml
  property :payment_response, Text
  property :verified_at, DateTime
  property :completed_at, DateTime
  timestamps :at

  validates_is_unique :external_id

  def verified?
    !verified_at.nil?
  end
  
  def verify
    self.update(:verified_at => Time.now)
  end
  
  def complete(payment_response)
    self.update(:payment_response => payment_response, :completed_at => Time.now)
  end
end
