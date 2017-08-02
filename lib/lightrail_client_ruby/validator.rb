module LightrailClientRuby
  class Validator
    def self.is_valid_charge_object? (charge_object)
      begin
        return true if ((charge_object.is_a? Hash) &&
            self.is_valid_code?(charge_object[:code]) &&
            self.is_valid_amount?(charge_object[:amount]) &&
            self.is_valid_currency?(charge_object[:currency]))
      rescue LightrailClientRuby::LightrailArgumentError
      end
        raise LightrailClientRuby::LightrailArgumentError.new("Invalid charge_object: #{charge_object}")
    end

    def self.is_valid_transaction_response? (transaction_response)
      begin
        return true if ((transaction_response.is_a? Hash) &&
            (transaction_response['transaction'].is_a? Hash) &&
            !transaction_response['transaction'].empty? &&
            self.is_valid_transaction_id?(transaction_response['transaction']['transactionId']) &&
            self.is_valid_card_id?(transaction_response['transaction']['cardId']))
      rescue LightrailClientRuby::LightrailArgumentError
      end
        raise LightrailClientRuby::LightrailArgumentError.new("Invalid transaction_response: #{transaction_response}")
    end

    def self.is_valid_fund_object? (fund_object)
      begin
        return true if ((fund_object.is_a? Hash) &&
            self.is_valid_card_id?(fund_object[:cardId]) &&
            self.is_valid_amount?(fund_object[:amount]) &&
            self.is_valid_currency?(fund_object[:currency]))
      rescue LightrailClientRuby::LightrailArgumentError
      end
        raise LightrailClientRuby::LightrailArgumentError.new("Invalid fund_object: #{fund_object}")
    end


    def self.is_valid_card_id? (card_id)
      return true if ((card_id.is_a? String) && !card_id.empty?)
      raise LightrailClientRuby::LightrailArgumentError.new("Invalid card_id: #{card_id}")
    end

    def self.is_valid_code? (code)
      return true if ((code.is_a? String) && !code.empty?)
      raise LightrailClientRuby::LightrailArgumentError.new("Invalid code: #{code}")
    end

    def self.is_valid_transaction_id? (transaction_id)
      return true if ((transaction_id.is_a? String) && !transaction_id.empty?)
      raise LightrailClientRuby::LightrailArgumentError.new("Invalid transaction_id: #{transaction_id}")
    end

    def self.is_valid_amount? (amount)
      return true if (amount.is_a? Integer)
      raise LightrailClientRuby::LightrailArgumentError.new("Invalid amount: #{amount}")
    end

    def self.is_valid_currency? (currency)
      return true if (/\A[A-Z]{3}\z/ === currency)
      raise LightrailClientRuby::LightrailArgumentError.new("Invalid currency: #{currency}")
    end
  end
end