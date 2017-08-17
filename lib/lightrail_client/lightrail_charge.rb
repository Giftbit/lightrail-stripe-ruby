module LightrailClient
  class LightrailCharge < LightrailClient::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour

    def self.create (charge_params)
      LightrailClient::Validator.validate_charge_object! (charge_params)
      charge_params_to_send_to_lightrail = LightrailClient::Translator.translate_charge_params(charge_params)

      charge_method = charge_params_to_send_to_lightrail[:code] ? 'code' : 'cardId'
      code_or_card_id = charge_params_to_send_to_lightrail.delete(charge_method.to_sym)

      response = (charge_method == 'code') ?
          LightrailClient::Connection.make_code_transaction(code_or_card_id, charge_params_to_send_to_lightrail) :
          LightrailClient::Connection.make_card_id_transaction(code_or_card_id, charge_params_to_send_to_lightrail)

      self.new(response['transaction'])
    end

    def self.cancel (original_transaction_response)
      handle_pending(original_transaction_response, 'void')
    end

    def self.capture (original_transaction_response)
      handle_pending(original_transaction_response, 'capture')
    end

    private

    def self.handle_pending (original_transaction_response, void_or_capture)
      LightrailClient::Validator.validate_transaction_response!(original_transaction_response)

      transaction_id = original_transaction_response.transactionId
      card_id = original_transaction_response.cardId

      body = {
          userSuppliedId: "#{transaction_id}-#{void_or_capture}",
      }

      response = LightrailClient::Connection.handle_pending(card_id, transaction_id, void_or_capture, body)

      self.new(response['transaction'])
    end

  end
end
