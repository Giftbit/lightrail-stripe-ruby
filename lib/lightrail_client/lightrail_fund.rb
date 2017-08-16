module LightrailClient
  class LightrailFund < LightrailClient::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour

    def self.create(fund_object)
      LightrailClient::Validator.validate_fund_object!(fund_object)

      fund_object_to_send_to_lightrail = LightrailClient::Translator.translate(fund_object, true)

      card_id = fund_object_to_send_to_lightrail.delete(:cardId)

      response = LightrailClient::Connection.make_card_id_transaction(card_id, fund_object_to_send_to_lightrail)

      self.new(response['transaction'])
    end
  end
end
