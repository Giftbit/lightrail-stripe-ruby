module LightrailClientRuby
  class Ping
    def self.ping
      url = LightrailClientRuby::Connection.api_endpoint_ping
      LightrailClientRuby::Connection.make_get_request_and_parse_response(url)
    end
  end
end