module LightrailClient
  class LightrailValue < LightrailClient::LightrailObject
    attr_accessor :principal, :attached, :currency, :cardType, :balanceDate, :cardId

    def self.retrieve (code)
      LightrailClient::Validator.validate_code! (code)

      url = LightrailClient::Connection.api_endpoint_code_balance(code)

      response = LightrailClient::Connection.make_get_request_and_parse_response(url)

      self.new(response['balance'])
    end


    def total_available
      total = self.principal['currentValue']
      self.attached.reduce(total) do |sum, valueStore|
        if valueStore['state'] == "ACTIVE"
          total += valueStore['currentValue']
        end
      end
      total
    end

  end
end