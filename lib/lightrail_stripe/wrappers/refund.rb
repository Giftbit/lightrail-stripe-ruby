module Lightrail
  class Refund < Lightrail::LightrailObject
    attr_accessor :transactionId, :value, :userSuppliedId, :dateCreated, :transactionType, :transactionAccessMethod, :giftbitUserId, :cardId, :currency, :parentTransactionId, :metadata, :codeLastFour

    def self.create(original_transaction_response, new_request_body = {})
      hash_of_original_transaction_response = original_transaction_response.clone
      hash_of_original_transaction_response = Lightrail::Translator.charge_instance_to_hash!(hash_of_original_transaction_response)

      Lightrail::Validator.validate_transaction_response! (hash_of_original_transaction_response)

      transaction_id = Lightrail::Validator.get_transaction_id(hash_of_original_transaction_response)

      body = new_request_body
      body[:userSuppliedId] ||= Lightrail::Validator.get_or_create_user_supplied_id_with_action_suffix(body, transaction_id, 'refund')

      response = Lightrail::Transaction.handle_transaction(hash_of_original_transaction_response, :refund, body)

      self.new(response)
    end

  end
end