module LightrailClientRuby
  class Validator
    def self.is_valid_charge_object? (charge_object)
      (charge_object.is_a? Hash) &&
          self.is_valid_code?(charge_object[:code]) &&
          self.is_valid_amount?(charge_object[:amount]) &&
          self.is_valid_currency?(charge_object[:currency])
    end

    def self.is_valid_transaction_response? (transaction_response)
      (transaction_response.is_a? Hash) &&
          (transaction_response['transaction'].is_a? Hash) &&
          !transaction_response['transaction'].empty? &&
          self.is_valid_transaction_id?(transaction_response['transaction']['transactionId']) &&
          self.is_valid_card_id?(transaction_response['transaction']['cardId'])
    end

    def self.is_valid_fund_object? (fund_object)
      (fund_object.is_a? Hash) &&
          self.is_valid_card_id?(fund_object[:cardId]) &&
          self.is_valid_amount?(fund_object[:amount]) &&
          self.is_valid_currency?(fund_object[:currency])
    end


    def self.is_valid_card_id? (card_id)
      (card_id.is_a? String) && !card_id.empty?
    end

    def self.is_valid_code? (code)
      (code.is_a? String) && !code.empty?
    end

    def self.is_valid_transaction_id? (transaction_id)
      (transaction_id.is_a? String) && !transaction_id.empty?
    end

    def self.is_valid_amount? (amount)
      amount.is_a? Integer
    end

    def self.is_valid_currency? (currency)
      /\A[A-Z]{3}\z/ === currency
    end
  end
end