module LightrailClient
  class Ping < LightrailClient::LightrailObject
    attr_accessor :username, :mode, :scopes, :roles, :effectiveScopes

    def self.ping
      url = LightrailClient::Connection.api_endpoint_ping
      response = LightrailClient::Connection.make_get_request_and_parse_response(url)
      LightrailClient::Validator.validate_ping_response!(response)
      self.new(response['user'])
    end
  end
end