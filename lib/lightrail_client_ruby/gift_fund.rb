module LightrailClientRuby
  class GiftFund

    def self.create(fund_object)
      if LightrailClientRuby::Validator.is_valid_fund_object?(fund_object)
        fund_object_to_send_to_lightrail = fund_object.clone
        card_id = fund_object_to_send_to_lightrail.delete(:cardId)
        fund_object_to_send_to_lightrail[:value] = fund_object_to_send_to_lightrail.delete(:amount)
        fund_object_to_send_to_lightrail[:userSuppliedId] ||= SecureRandom::uuid

        resp = Connection::connection.post do |req|
          req.url "cards/#{card_id}/transactions"
          req.body = JSON.generate(fund_object_to_send_to_lightrail)
        end

        JSON.parse(resp.body)

      else
        raise ArgumentError.new("Invalid fund_object")
      end
    end
  end
end
