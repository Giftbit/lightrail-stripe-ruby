module LightrailClient
  class Ping < LightrailClient::LightrailObject
    attr_accessor :username, :mode, :scopes, :roles, :effectiveScopes

    def self.ping
      response = LightrailClient::Connection.ping
      LightrailClient::Validator.validate_ping_response!(response)
      self.new(response['user'])
    end
  end
end