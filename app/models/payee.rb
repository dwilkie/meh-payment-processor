require 'money'
class Payee
  include DataMapper::Resource
  property :id, Serial
  property :email, String, :format => :email_address, :required => true
  property :name, String
  property :cents, Integer
  property :currency, String
  
  def maximum_amount=(amount)
    self.cents = amount.to_money.cents
  end
  
  def maximum_amount
    Money.new(self.cents, self.currency)
  end
  
end
