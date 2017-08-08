module LightrailClientRuby
  class Refund < LightrailClientRuby::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :valueAvailableAfterTransaction, :giftbitUserId, :cardId, :currency, :parentTransactionId, :metadata, :codeLastFour

    def self.create(original_transaction_response)
      LightrailClientRuby::Validator.validate_transaction_response! (original_transaction_response)

      card_id = original_transaction_response.cardId || original_transaction_response['transaction']['cardId']
      transaction_id = original_transaction_response.transactionId || original_transaction_response['transaction']['transactionId']

      url = LightrailClientRuby::Connection.api_endpoint_refund_transaction(card_id, transaction_id)
      body = {
          userSuppliedId: "#{transaction_id}-refund"
      }

      response = LightrailClientRuby::Connection.make_post_request_and_parse_response(url, body)

      LightrailClientRuby::Validator.validate_transaction_response! (response)
      self.new(response['transaction'])
    end

  end
end