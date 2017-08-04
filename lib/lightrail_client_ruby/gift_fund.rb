module LightrailClientRuby
  class GiftFund < LightrailClientRuby::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :valueAvailableAfterTransaction, :giftbitUserId, :cardId, :currency, :codeLastFour

    def self.create(fund_object)
      LightrailClientRuby::Validator.validate_fund_object!(fund_object)

      fund_object_to_send_to_lightrail = LightrailClientRuby::Translator.translate(fund_object, true)

      card_id = fund_object_to_send_to_lightrail.delete(:cardId)

      url = LightrailClientRuby::Connection.api_endpoint_card_transaction(card_id)

      response = LightrailClientRuby::Connection.make_post_request_and_parse_response(url, fund_object_to_send_to_lightrail)

      self.new(response['transaction'])
    end
  end
end
