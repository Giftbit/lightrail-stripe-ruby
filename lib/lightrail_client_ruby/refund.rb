module LightrailClientRuby
  class Refund

    def self.create(original_transaction_response)
      LightrailClientRuby::Validator.is_valid_transaction_response? (original_transaction_response)

      card_id = original_transaction_response['transaction']['cardId']
      transaction_id = original_transaction_response['transaction']['transactionId']

      url = LightrailClientRuby::Connection.api_endpoint_refund_transaction(card_id, transaction_id)
      body = {
          userSuppliedId: "#{transaction_id}-refund"
      }

      LightrailClientRuby::Connection.make_post_request_and_parse_response(url, body)
    end

  end
end