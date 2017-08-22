module Lightrail
  class Ping < Lightrail::LightrailObject
    attr_accessor :username, :mode, :scopes, :roles, :effectiveScopes

    def self.ping
      response = Lightrail::Connection.ping
      Lightrail::Validator.validate_ping_response!(response)
      self.new(response['user'])
    end
  end
end