require 'money'
class Payee
  include DataMapper::Resource
  property :id, Serial
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :name, String
  property :cents, Integer, :default => 0
  property :currency, String

  validates_presence_of :currency, :unless => Proc.new {|p| p.maximum_amount.zero?}

  CURRENCIES = %w[ AUD BRL CAD CZK DKK EUR HKD HUF ILS JPY MYR MXN NOK NZD
                          PHP PLN GBP SGD SEK CHF TWD THB USD ]

  def maximum_amount=(amount)
    self.cents = amount.to_money.cents
  end

  def maximum_amount
    self.currency = nil if self.currency.blank?
    Money.new(self.cents, self.currency)
  end

  def name
    (@name.blank? && !email.blank?) ? email.split("@").first.capitalize : @name
  end

  def pay_unlimited?
    maximum_amount.zero?
  end

  def self.authorization_errors(params)
    errors = nil
    if params["email"] && params["amount"] && params["currency"]
      if self.restrict?
        payee = self.first(:email => params["email"])
        if payee
          unless payee.pay_unlimited?
            maximum_amount = payee.maximum_amount
            if maximum_amount.currency == params["currency"].to_currency
              amount = params["amount"] << " " << params["currency"]
              if maximum_amount < amount.to_money
                errors = {"payee_maximum_amount_exceeded" => true}
              end
            else
              errors = {"payee_currency_invalid" => true}
            end
          end
        else
          errors = {"payee_not_found" => true}
        end
      end
    else
      errors = {"invalid_payee_details" => true}
    end
    errors = {"errors" => errors} if errors
    errors
  end

  private
    def self.restrict?
      self.count > 0
    end
end

