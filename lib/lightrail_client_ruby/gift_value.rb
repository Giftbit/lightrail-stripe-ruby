module LightrailClientRuby
  class GiftValue
    def self.retrieve (code)

      if LightrailClientRuby::Validator.is_valid_code? (code)
        url = LightrailClientRuby::Connection.api_endpoint_code_balance(code)
        LightrailClientRuby::Connection.make_get_request_and_parse_response(url)

      else
        raise LightrailClientRuby::LightrailArgumentError.new("Invalid fund_object")
      end

    end
  end
end