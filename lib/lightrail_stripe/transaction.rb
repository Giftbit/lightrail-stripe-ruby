module Lightrail
  class Transaction < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour, :metadata, :parentTransactionId

    # PSEUDO CODE
    # transaction_type comes from Constants list: [:code_drawdown, card_id_drawdown, :code_pending, :card_id_pending, :fund, :refund, :capture, :void]
    def self.create(transaction_params, transaction_type)
      # Validate the params based on the type of transaction being created
      transaction_params_for_lightrail = Lightrail::Validator.send("set_params_for_#{transaction_type}!", transaction_params)
      response = Lightrail::Connection.send(transaction_type, transaction_params_for_lightrail)
    end

    def self.charge(transaction_params, transaction_type)
      self.create(transaction_params, transaction_type)
    end

    def self.fund(transaction_params)
      self.create(transaction_params, :card_id_fund)
    end


    def self.refund!(original_transaction_info, new_request_body=nil)
      handle_transaction(original_transaction_info, 'refund', new_request_body)
    end

    def self.cancel! (original_transaction_info, new_request_body=nil)
      handle_transaction(original_transaction_info, 'void', new_request_body)
    end

    def self.capture! (original_transaction_info, new_request_body=nil)
      handle_transaction(original_transaction_info, 'capture', new_request_body)
    end

    private

    # UPDATE THIS!
    def handle_transaction (original_transaction_info, action, new_request_body=nil)
      Lightrail::Validator.validate_transaction_info!(original_transaction_info)

      transaction_id = original_transaction_info['transactionId'] || original_transaction_info['transaction_id']
      card_id = original_transaction_info['cardId'] || original_transaction_info['card_id']

      body = new_request_body || {}
      body[:userSuppliedId] ||= Lightrail::Translator.get_or_create_user_supplied_id_with_action_suffix(body, transaction_id, action)

      response = Lightrail::Connection.handle_pending(card_id, transaction_id, action, body)

      Lightrail::LightrailCharge.new(response['transaction'])
    end

  end
end
