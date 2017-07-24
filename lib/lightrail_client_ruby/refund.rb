module LightrailClientRuby
  class Refund

    def self.create(transaction_object)
      card_id = transaction_object['transaction']['cardId']
      transaction_id = transaction_object['transaction']['transactionId']

      resp = Connection.connection.post do |req|
        req.url "cards/#{card_id}/transactions/#{transaction_id}/refund"
        req.body = JSON.generate({userSuppliedId: "#{transaction_id}-refund"})
      end

      JSON.parse(resp.body)
    end

  end
end