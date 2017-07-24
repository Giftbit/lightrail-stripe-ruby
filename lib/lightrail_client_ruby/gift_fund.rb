module LightrailClientRuby
  class GiftFund

    def self.create(fund_object)
      fund_object_to_send_to_lightrail = fund_object.clone
      card_id = fund_object_to_send_to_lightrail.delete(:cardId)
      fund_object_to_send_to_lightrail[:value] = fund_object_to_send_to_lightrail.delete(:amount)

      resp = Connection::connection.post do |req|
        req.url "#{Connection.api_base}/cards/#{card_id}/transactions"
        req.body = JSON.generate(fund_object_to_send_to_lightrail)
      end

      JSON.parse(resp.body)
    end

  end
end
