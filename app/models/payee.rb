require 'money'
class Payee
  include DataMapper::Resource
  property :id, Serial
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :name, String
  property :cents, Integer, :default => 0
  property :currency, String
  
  validates_present :currency, :unless => Proc.new {|p| p.maximum_amount.zero?}

  CURRENCIES = %w[ AUD BRL CAD CZK DKK EUR HKD HUF ILS JPY MYR MXN NOK NZD
                          PHP PLN GBP SGD SEK CHF TWD THB USD ]

  def maximum_amount=(amount)
    self.cents = amount.to_money.cents
  end
  
  def maximum_amount
    self.currency = nil if self.currency.blank?
    Money.new(self.cents, self.currency)
  end

end
