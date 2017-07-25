module LightrailClientRuby
  class Validator
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