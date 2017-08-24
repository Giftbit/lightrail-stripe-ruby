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


    def self.refund (original_transaction_info, new_request_body={})
      handle_transaction(original_transaction_info, 'refund', new_request_body)
    end

    def self.void (original_transaction_info, new_request_body={})
      handle_transaction(original_transaction_info, 'void', new_request_body)
    end

    def self.capture (original_transaction_info, new_request_body={})
      handle_transaction(original_transaction_info, 'capture', new_request_body)
    end

    private

    def self.create(transaction_params, transaction_type)
      transaction_params_for_lightrail = Lightrail::Validator.send("set_params_for_#{transaction_type}!", transaction_params)
      response = Lightrail::Connection.send(transaction_type, transaction_params_for_lightrail)
    end

    def self.handle_transaction (original_transaction_info, action, new_request_body={})
      transaction_params_for_lightrail = Lightrail::Validator.set_params_for_acting_on_existing_transaction!(original_transaction_info, new_request_body)
      response = Lightrail::Connection.send(action, transaction_params_for_lightrail)
    end

  end
end
