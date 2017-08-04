module LightrailClientRuby
  class Ping < LightrailClientRuby::LightrailObject
    attr_accessor :username, :mode, :scopes, :roles, :effectiveScopes

    def self.ping
      url = LightrailClientRuby::Connection.api_endpoint_ping
      response = LightrailClientRuby::Connection.make_get_request_and_parse_response(url)
      LightrailClientRuby::Validator.validate_ping_response!(response)
      self.new(response['user'])
    end
  end
end