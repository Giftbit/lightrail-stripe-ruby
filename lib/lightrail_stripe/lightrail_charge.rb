module Lightrail
  class LightrailCharge < Lightrail::Transaction
    # attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour, :metadata

    def self.create (charge_params)
      Lightrail::Validator.validate_charge_object! (charge_params)
      charge_params_to_send_to_lightrail = Lightrail::Translator.translate_charge_params(charge_params)
      charge_method = case
                        when charge_params_to_send_to_lightrail[:code] && charge_params_to_send_to_lightrail[:pending]
                          :code_pending
                        when charge_params_to_send_to_lightrail[:cardId] && charge_params_to_send_to_lightrail[:pending]
                          :card_id_pending
                        when charge_params_to_send_to_lightrail[:code]
                          :code_drawdown
                        when charge_params_to_send_to_lightrail[:cardId]
                          :card_id_drawdown
                      end

      transaction = Lightrail::Transaction.charge(charge_params_to_send_to_lightrail, charge_method)
      self.new(transaction)
    end


    def cancel! (new_request_body=nil)
      handle_pending(self, 'void', new_request_body)
    end

    def capture! (new_request_body=nil)
      handle_pending(self, 'capture', new_request_body)
    end

    private

    def handle_pending (original_transaction_response, void_or_capture, new_request_body=nil)
      Lightrail::Validator.validate_transaction_response!(original_transaction_response)

      transaction_id = original_transaction_response.transactionId
      card_id = original_transaction_response.cardId


      body = new_request_body || {}
      body[:userSuppliedId] ||= Lightrail::Translator.get_or_create_user_supplied_id_with_action_suffix(body, transaction_id, void_or_capture)

      response = Lightrail::Connection.handle_pending(card_id, transaction_id, void_or_capture, body)

      Lightrail::LightrailCharge.new(response['transaction'])
    end

  end
end
