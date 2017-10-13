module Lightrail
  class LightrailFund < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour

    def self.create(fund_object)
      Lightrail::Validator.validate_fund_object!(fund_object)

      fund_object_to_send_to_lightrail = Lightrail::Translator.translate_fund_params(fund_object)

      response = Lightrail::Card.fund(fund_object_to_send_to_lightrail)

      self.new(response)
    end
  end
end
