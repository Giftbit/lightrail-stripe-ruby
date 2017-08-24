module Lightrail
  class Transaction < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :codeLastFour, :metadata, :parentTransactionId

    def self.charge_code(transaction_params)
      transaction_type = transaction_params[:pending] ? :code_pending : :code_drawdown
      self.create(transaction_params, transaction_type)
    end

    def self.charge_card(transaction_params)
      transaction_type = transaction_params[:pending] ? :card_id_pending : :card_id_drawdown
      self.create(transaction_params, transaction_type)
    end

    def self.fund_card(transaction_params)
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

    def self.create(transaction_params, transaction_type)
      transaction_params_for_lightrail = Lightrail::Validator.send("set_params_for_#{transaction_type}!", transaction_params)
      response = Lightrail::Connection.send(transaction_type, transaction_params_for_lightrail)
    end

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
