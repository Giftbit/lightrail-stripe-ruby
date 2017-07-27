module LightrailClientRuby
  class GiftValue
    def self.retrieve (code)
      url = LightrailClientRuby::Connection.api_endpoint_code_balance(code)
      LightrailClientRuby::Connection.make_get_request_and_parse_response(url)
    end
  end
end