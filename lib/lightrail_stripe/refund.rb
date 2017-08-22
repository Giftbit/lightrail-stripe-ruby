module Lightrail
  class Refund < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :parentTransactionId, :metadata, :codeLastFour

    def self.create(original_transaction_response)
      Lightrail::Validator.validate_transaction_response! (original_transaction_response)

      card_id = original_transaction_response.cardId
      transaction_id = original_transaction_response.transactionId

      # TODO: take userSuppliedId if provided in params
      body = {
          userSuppliedId: "#{transaction_id}-refund"
      }

      response = Lightrail::Connection.post_refund(card_id, transaction_id, body)

      self.new(response['transaction'])
    end

  end
end