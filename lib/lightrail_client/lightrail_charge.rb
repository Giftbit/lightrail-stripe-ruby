module LightrailClient
  class LightrailCharge < LightrailClient::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour

    def self.create (charge_params)
      LightrailClient::Validator.validate_charge_object! (charge_params)
      charge_params_to_send_to_lightrail = LightrailClient::Translator.translate(charge_params)

      charge_method = charge_params_to_send_to_lightrail[:code] ? 'code' : 'cardId'
      code_or_card_id = charge_params_to_send_to_lightrail.delete(charge_method.to_sym)

      url = (charge_method == 'code') ?
          LightrailClient::Connection.api_endpoint_code_transaction(code_or_card_id) :
          LightrailClient::Connection.api_endpoint_card_transaction(code_or_card_id)

      response = LightrailClient::Connection.make_post_request_and_parse_response(url, charge_params_to_send_to_lightrail)

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

      url = LightrailClient::Connection.api_endpoint_handle_pending(card_id, transaction_id, void_or_capture)
      body = {
          userSuppliedId: "#{transaction_id}-#{void_or_capture}",
      }

      response = LightrailClient::Connection.make_post_request_and_parse_response(url, body)

      self.new(response['transaction'])
    end

  end
end
