class PaymentRequest
  include DataMapper::Resource
  property :id, Serial
  property :external_id, Integer, :required => true, :unique => true
  property :payment_params, Yaml, :required => true
  property :payee_params, Yaml,   :required => true
  property :payment_response, Text
  property :internal_errors, Text
  property :verified_at, DateTime
  property :sent_for_processing_at, DateTime
  property :completed_at, DateTime
  property :status, String
  timestamps :at

  def initialize(params)
    self.external_id = params["external_id"]
    self.payee_params = params["payee"]
    self.payment_params = params["payment"]
  end

  def params
    { "payment" => payment_params, "payee" => payee_params, "external_id" => external_id.to_s }
  end

  def verified?
    !verified_at.nil?
  end

  def authorized?
    verified? && !unauthorized?
  end

  def unauthorized?
    status == "internally_unauthorized" ||
    status == "externally_unauthorized"
  end

  def sent_for_processing?
    !sent_for_processing_at.nil?
  end

  def completed?
    !completed_at.nil?
  end

  def send_for_processing
    self.update(:sent_for_processing_at => Time.now)
  end

  def verify
    self.update(:verified_at => Time.now)
  end

  def complete(payment_response)
    payment_response = payment_response.from_query
    payment_response = {"payment_response" => payment_response}
    self.update(
      :payment_response => payment_response.to_query,
      :completed_at => Time.now
    )
  end

  def internally_unauthorize(errors)
    errors = {"errors" => errors}.to_query
    self.update(
      :status => "internally_unauthorized",
      :internal_errors => errors
    )
  end

  def externally_unauthorize
    self.update(:status => "externally_unauthorized")
  end

  def notification
    notification = self.internal_errors ? self.internal_errors : self.payment_response
    notification.from_query
  end
end

