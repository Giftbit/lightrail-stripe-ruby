module LightrailClientRuby
  class GiftValue < LightrailClientRuby::LightrailObject
    attr_accessor :principal, :attached, :currency, :cardType, :balanceDate, :cardId

    def self.retrieve (code)
      LightrailClientRuby::Validator.validate_code! (code)

      url = LightrailClientRuby::Connection.api_endpoint_code_balance(code)

      response = LightrailClientRuby::Connection.make_get_request_and_parse_response(url)

      self.new(response['balance'])
    end
  end
end