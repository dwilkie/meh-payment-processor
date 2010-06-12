# Represents the remote PaymentRequest resource
class RemotePaymentRequest
  def initialize(remote_application_uri)
    @remote_application_uri = remote_application_uri
  end

  def verify(payment_request)
    params = payment_request.params
    id = params.delete("remote_id")
    uri = URI.join(
      @remote_application_uri,
      "payment_requests/#{id}"
    )
    uri.query = params.to_query
    uri = uri.to_s
    AppEngine::URLFetch.fetch(
      uri,
      :method => 'HEAD'
    ).code == "200" ? payment_request.verify : payment_request.remotely_unauthorize
  end

  def notify(payment_request)
    uri = URI.join(
      @remote_application_uri,
      "payment_requests/#{payment_request.remote_id}"
    )
    notification = payment_request.notification.merge(
      "id" => payment_request.id.to_s
    )
    notification = {"payment_request" => notification}.to_query
    AppEngine::URLFetch.fetch(
      uri.to_s,
      :payload => notification,
      :method => 'PUT',
      :follow_redirects => false,
      :headers => {"Content-Type" => "application/x-www-form-urlencoded"}
    )
    payment_request.update(:notification_sent_at => Time.now)
  end
end

