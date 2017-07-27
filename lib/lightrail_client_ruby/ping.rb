module LightrailClientRuby
  class Ping
    def self.ping
      LightrailClientRuby::Connection.make_get_request_and_parse_response("ping")
    end
  end
end