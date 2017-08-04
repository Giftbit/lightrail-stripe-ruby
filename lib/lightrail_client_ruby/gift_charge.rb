module LightrailClientRuby
  class GiftCharge < LightrailClientRuby::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :valueAvailableAfterTransaction, :giftbitUserId, :cardId, :currency, :codeLastFour

    def self.create (charge_object)
      LightrailClientRuby::Validator.validate_charge_object! (charge_object)

      charge_object_to_send_to_lightrail = LightrailClientRuby::Translator.translate(charge_object)
      code = charge_object_to_send_to_lightrail.delete(:code)

      url = LightrailClientRuby::Connection.api_endpoint_code_transaction(code)

      response = LightrailClientRuby::Connection.make_post_request_and_parse_response(url, charge_object_to_send_to_lightrail)

      LightrailClientRuby::Validator.validate_transaction_response! (response)
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
      LightrailClientRuby::Validator.validate_transaction_response!(original_transaction_response)

      transaction_id = original_transaction_response.transactionId || original_transaction_response['transaction']['transactionId']
      card_id = original_transaction_response.cardId || original_transaction_response['transaction']['cardId']

      url = LightrailClientRuby::Connection.api_endpoint_handle_pending(card_id, transaction_id, void_or_capture)
      body = {
          userSuppliedId: "#{transaction_id}-#{void_or_capture}",
      }

      response = LightrailClientRuby::Connection.make_post_request_and_parse_response(url, body)

      LightrailClientRuby::Validator.validate_transaction_response!(response)
      self.new(response['transaction'])
    end

  end
end
