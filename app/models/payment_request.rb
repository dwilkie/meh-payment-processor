class PaymentRequest
  include DataMapper::Resource
  property :id, Serial
  property :external_id, Integer, :required => true
  property :params, Yaml
  property :verified_at, DateTime
  timestamps :at

  validates_is_unique :external_id

  def verified?
    !verified_at.nil?
  end
  
  def verify
    self.update(:verified_at => Time.now)
  end
  
end
