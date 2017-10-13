module Lightrail
  class LightrailCharge < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour, :metadata

    def self.create (charge_params)
      Lightrail::Validator.validate_charge_object! (charge_params)
      charge_params_to_send_to_lightrail = Lightrail::Translator.translate_charge_params(charge_params)

      charge_method = charge_params_to_send_to_lightrail[:code] ? 'code' : 'cardId'

      response = (charge_method == 'code') ?
          Lightrail::Code.charge(charge_params_to_send_to_lightrail) :
          Lightrail::Card.charge(charge_params_to_send_to_lightrail)

      self.new(response)
    end


    def cancel! (new_request_body=nil)
      handle_pending(self, 'void', new_request_body)
    end

    def capture! (new_request_body=nil)
      handle_pending(self, 'capture', new_request_body)
    end

    private

    def handle_pending (original_transaction_response, void_or_capture, new_request_body=nil)

      hash_of_original_transaction_response = original_transaction_response.clone
      hash_of_original_transaction_response = Lightrail::Translator.charge_instance_to_hash!(hash_of_original_transaction_response)

      Lightrail::Validator.validate_transaction_response!(hash_of_original_transaction_response)

      transaction_id = Lightrail::Validator.get_transaction_id(hash_of_original_transaction_response)

      body = new_request_body || {}
      body[:userSuppliedId] ||= Lightrail::Validator.get_or_create_user_supplied_id_with_action_suffix(body, transaction_id, void_or_capture)

      response = Lightrail::Transaction.handle_transaction(hash_of_original_transaction_response, void_or_capture, body)

      Lightrail::LightrailCharge.new(response)
    end

  end
end
