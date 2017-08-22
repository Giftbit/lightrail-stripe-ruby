module Lightrail
  class LightrailCharge < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour, :metadata

    def self.create (charge_params)
      Lightrail::Validator.validate_charge_object! (charge_params)
      charge_params_to_send_to_lightrail = Lightrail::Translator.translate_charge_params(charge_params)

      charge_method = charge_params_to_send_to_lightrail[:code] ? 'code' : 'cardId'
      code_or_card_id = charge_params_to_send_to_lightrail.delete(charge_method.to_sym)

      response = (charge_method == 'code') ?
          Lightrail::Connection.make_code_transaction(code_or_card_id, charge_params_to_send_to_lightrail) :
          Lightrail::Connection.make_card_id_transaction(code_or_card_id, charge_params_to_send_to_lightrail)

      self.new(response['transaction'])
    end

    def self.cancel (original_transaction_response, new_request_body=nil)
      handle_pending(original_transaction_response, 'void', new_request_body)
    end

    def self.capture (original_transaction_response, new_request_body=nil)
      handle_pending(original_transaction_response, 'capture', new_request_body)
    end

    private

    def self.handle_pending (original_transaction_response, void_or_capture, new_request_body=nil)
      Lightrail::Validator.validate_transaction_response!(original_transaction_response)

      transaction_id = original_transaction_response.transactionId
      card_id = original_transaction_response.cardId


      body = new_request_body || {}
      body[:userSuppliedId] ||= Lightrail::Translator.get_or_create_user_supplied_id_with_action_suffix(body, transaction_id, void_or_capture)

      response = Lightrail::Connection.handle_pending(card_id, transaction_id, void_or_capture, body)

      self.new(response['transaction'])
    end

  end
end
