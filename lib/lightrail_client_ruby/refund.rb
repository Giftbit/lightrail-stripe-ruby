module LightrailClientRuby
  class Refund

    def self.create(transaction_object)
      card_id = transaction_object['transaction']['cardId']
      transaction_id = transaction_object['transaction']['transactionId']

      url = LightrailClientRuby::Connection.api_endpoint_refund_transaction(card_id, transaction_id)
      body = {
          userSuppliedId: "#{transaction_id}-refund"
      }

      LightrailClientRuby::Connection.make_post_request_and_parse_response(url, body)
    end

  end
end