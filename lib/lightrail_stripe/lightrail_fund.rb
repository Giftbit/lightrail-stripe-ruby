module Lightrail
  class LightrailFund < Lightrail::Transaction
    # attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour


    def self.create(fund_object)
      Lightrail::Validator.validate_fund_object!(fund_object)

      fund_object_to_send_to_lightrail = Lightrail::Translator.translate_fund_params(fund_object)

      card_id = fund_object_to_send_to_lightrail.delete(:cardId)

      response = Lightrail::Connection.make_card_id_transaction(card_id, fund_object_to_send_to_lightrail)

      self.new(response['transaction'])
    end
  end
end
