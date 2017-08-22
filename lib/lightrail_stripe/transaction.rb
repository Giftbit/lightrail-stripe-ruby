module Lightrail
  class Transaction < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour, :metadata, :parentTransactionId

    # PSEUDO CODE
    # transaction_type comes from Constants list: [:code_drawdown, card_id_drawdown, :code_pending, :card_id_pending, :fund, :refund, :capture, :void]
    def self.create(transaction_params, transaction_type)
      # Validate the params based on the type of transaction being created
      Lightrail::Validator.send(transaction_type, transaction_params)
      Lightrail::Connection.send(transaction_type, transaction_params)
    end





    def refund!(new_request_body=nil)
      handle_transaction(self, 'refund', new_request_body)
    end

    def cancel! (new_request_body=nil)
      handle_transaction(self, 'void', new_request_body)
    end

    def capture! (new_request_body=nil)
      handle_transaction(self, 'capture', new_request_body)
    end

    private

    # UPDATE THIS!
    def handle_transaction (original_transaction_response, action, new_request_body=nil)
      Lightrail::Validator.validate_transaction_response!(original_transaction_response)

      transaction_id = original_transaction_response.transactionId
      card_id = original_transaction_response.cardId

      body = new_request_body || {}
      body[:userSuppliedId] ||= Lightrail::Translator.get_or_create_user_supplied_id_with_action_suffix(body, transaction_id, action)

      response = Lightrail::Connection.handle_pending(card_id, transaction_id, action, body)

      Lightrail::LightrailCharge.new(response['transaction'])
    end

  end
end
