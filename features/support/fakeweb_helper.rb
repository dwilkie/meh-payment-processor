module FakeWebHelper
  def register_external_payment_request(method, status)
    FakeWeb.register_uri(
      method,
      %r|http://localhost:3000/payment_request/\d+(?:\?[^\s\?]+)?|,
      :status => status
    )
  end
  
  def register_paypal_payment_request(options={})
    options[:fail] ||= false
    unless options[:fail]
      response = "HTTP/1.1 200 OK\r\nDate: Fri, 04 Jun 2010 16:55:36 GMT\r\nServer: Apache-Coyote/1.1\r\nX-PAYPAL-SERVICE-VERSION: 1.3.0\r\nX-EBAY-SOA-MESSAGE-PROTOCOL: NONE\r\nX-EBAY-SOA-RESPONSE-DATA-FORMAT: NV\r\nX-PAYPAL-SERVICE-NAME: {http://svcs.paypal.com/types/ap}AdaptivePayments\r\nX-PAYPAL-OPERATION-NAME: Pay\r\nX-EBAY-SOA-REQUEST-GUID: 12903e39-6ea0-abfc-49b7-0687ffffd0ac\r\nContent-Type: text/plain;charset=UTF-8\r\nSet-Cookie: Apache=10.191.196.11.1275670533834964; path=/; expires=Thu, 21-Apr-04 10:27:17 GMT\r\nVary: Accept-Encoding\r\nTransfer-Encoding: chunked\r\n\r\nresponseEnvelope.timestamp=2010-06-04T09%3A55%3A36.507-07%3A00&responseEnvelope.ack=Success&responseEnvelope.correlationId=1ddf86263c63d&responseEnvelope.build=1310729&payKey=AP-4MV83827NG0173616&paymentExecStatus=COMPLETED"
    end
    
    FakeWeb.register_uri(
      :post,
      "https://svcs.sandbox.paypal.com/AdaptivePayments/Pay",
      :response => response
    )
  end
  
  def external_payment_request_uri(id, fields=nil)
    uri = "http://localhost:3000/payment_request/#{id}"
    uri << "?#{fields.to_params}" if fields
    uri
  end

  def paypal_payments_uri
    "https://svcs.sandbox.paypal.com/AdaptivePayments/Pay"
  end
end
