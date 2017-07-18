module LightrailClientRuby
  class GiftCharge
    def self.create (charge_object)

      charge_object_to_send_to_lightrail = charge_object.clone # TODO: decide whether it is problematic to use a shallow copy of the charge_object arg
      code = charge_object_to_send_to_lightrail.delete(:code)

      # Replace positive 'amount' to charge (Stripe expectation) with negative 'value' to charge (Lightrail expectation)
      charge_object_to_send_to_lightrail[:value] = -charge_object_to_send_to_lightrail.delete(:amount)
      # Replace 'capture' (Stripe expectation) with 'pending' (Lightrail expectation), using inverse value if key is present
      # charge_object_to_send_to_lightrail[:pending] = charge_object_to_send_to_lightrail[:capture] === nil ? false : !charge_object_to_send_to_lightrail.delete(:capture)
      charge_object_to_send_to_lightrail[:pending] = !charge_object_to_send_to_lightrail.delete(:capture)

      resp = Connection.connection.post do |req|
        req.url "#{Connection.api_base}/codes/#{code}/transactions"
        req.body = JSON.generate(charge_object_to_send_to_lightrail)
      end

      JSON.parse(resp.body)
    end

    def self.cancel (original_transaction_response)
      handle_pending(original_transaction_response, 'void')
    end

    def self.capture (original_transaction_response)
      handle_pending(original_transaction_response, 'capture')
    end

    private

    def self.handle_pending (original_transaction_response, void_or_capture)
      transaction_id = original_transaction_response['transaction']['transactionId']
      card_id = original_transaction_response['transaction']['cardId']
      body = {
          userSuppliedId: "ruby-handle-pending-#{void_or_capture}-" + rand().to_s,
      }

      resp = Connection.connection.post do |req|
        req.url "#{Connection.api_base}/cards/#{card_id}/transactions/#{transaction_id}/#{void_or_capture}"
        req.body = JSON.generate(body)
      end

      JSON.parse(resp.body)
    end

  end
end
