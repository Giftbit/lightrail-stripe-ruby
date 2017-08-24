module Lightrail
  class Refund < Lightrail::Transaction
    # attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :parentTransactionId, :metadata, :codeLastFour

    def self.create(original_transaction_response)
      Lightrail::Validator.validate_transaction_response! (original_transaction_response)

      # TODO: take userSuppliedId if provided in params
      original_transaction_info = Lightrail::Translator.charge_instance_to_hash!(original_transaction_response)

      transaction = Lightrail::Transaction.refund(original_transaction_info, {userSuppliedId: "#{original_transaction_response.transactionId}-refund"})
      self.new(transaction)
    end

  end
end