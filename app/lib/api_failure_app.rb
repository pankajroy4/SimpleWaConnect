class ApiFailureApp < Devise::FailureApp
  def respond
    if api_request?
      json_api_error_response
    else
      super
    end
  end

  def json_api_error_response
    self.status = 401
    self.content_type = "application/json"
    self.response_body = { error: "Unauthorized" }.to_json
  end

  private

  def api_request?
    request.path.start_with?("/api/")
  end
end
