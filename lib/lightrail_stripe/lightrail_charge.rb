module Lightrail
  class LightrailCharge < Lightrail::Transaction
    # attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour, :metadata

    def self.create (charge_params)
      Lightrail::Validator.validate_charge_object! (charge_params)
      charge_params_to_send_to_lightrail = Lightrail::Translator.translate_charge_params(charge_params)
      charge_method = charge_params_to_send_to_lightrail[:code] ? 'code' : 'card'

      transaction = Lightrail::Transaction.public_send("charge_#{charge_method}", charge_params_to_send_to_lightrail)
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

      body = new_request_body || {}
      body[:userSuppliedId] ||= Lightrail::Translator.get_or_create_user_supplied_id_with_action_suffix(body, original_transaction_response.transactionId, void_or_capture)

      original_transaction_info = Lightrail::Translator.charge_instance_to_hash!(original_transaction_response)

      transaction = Lightrail::Transaction.public_send(void_or_capture, original_transaction_info, body)
      Lightrail::LightrailCharge.new(transaction)
    end

  end
end
