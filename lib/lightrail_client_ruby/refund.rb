module LightrailClientRuby
  class Refund

    def self.create(transaction_object)
      card_id = transaction_object['transaction']['cardId']
      transaction_id = transaction_object['transaction']['transactionId']

      body = {
          userSuppliedId: "#{transaction_id}-refund"
      }

      LightrailClientRuby::Connection.make_post_request_and_parse_response("cards/#{card_id}/transactions/#{transaction_id}/refund", body)
    end

  end
end