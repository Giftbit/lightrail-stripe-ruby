module LightrailClientRuby
  class GiftFund

    def self.create(fund_object)
      if LightrailClientRuby::Validator.is_valid_fund_object?(fund_object)
        fund_object_to_send_to_lightrail = fund_object.clone
        card_id = fund_object_to_send_to_lightrail.delete(:cardId)
        fund_object_to_send_to_lightrail[:value] = fund_object_to_send_to_lightrail.delete(:amount)
        fund_object_to_send_to_lightrail[:userSuppliedId] ||= SecureRandom::uuid

        url = LightrailClientRuby::Connection.api_endpoint_card_transaction(card_id)

        LightrailClientRuby::Connection.make_post_request_and_parse_response(url, fund_object_to_send_to_lightrail)

      else
        raise ArgumentError.new("Invalid fund_object")
      end
    end
  end
end
