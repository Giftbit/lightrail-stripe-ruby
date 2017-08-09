module LightrailClient
  class Refund < LightrailClient::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :valueAvailableAfterTransaction, :giftbitUserId, :cardId, :currency, :parentTransactionId, :metadata, :codeLastFour

    def self.create(original_transaction_response)
      LightrailClient::Validator.validate_transaction_response! (original_transaction_response)

      card_id = original_transaction_response.cardId
      transaction_id = original_transaction_response.transactionId

      url = LightrailClient::Connection.api_endpoint_refund_transaction(card_id, transaction_id)
      body = {
          userSuppliedId: "#{transaction_id}-refund"
      }

      response = LightrailClient::Connection.make_post_request_and_parse_response(url, body)

      self.new(response['transaction'])
    end

  end
end