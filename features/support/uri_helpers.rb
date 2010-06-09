module URIHelpers
  def stringify_body(body)
    req = Net::HTTP::Post.new("/some_path")
    req.set_form_data(body)
    req.body
  end
end

