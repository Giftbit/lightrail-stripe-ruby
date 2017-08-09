module LightrailClient
  class Validator
    def self.validate_charge_object! (charge_params)
      begin
        return true if ((charge_params.is_a? Hash) &&
            self.validate_code!(charge_params[:code]) &&
            self.validate_amount!(charge_params[:amount]) &&
            self.validate_currency!(charge_params[:currency]))
      rescue LightrailClient::LightrailArgumentError
      end
        raise LightrailClient::LightrailArgumentError.new("Invalid charge_params: #{charge_params}")
    end

    def self.validate_transaction_response! (transaction_response)
      begin
        return true if (transaction_response.is_a? LightrailClient::LightrailCharge) && transaction_response.transactionId && transaction_response.cardId
      rescue LightrailClient::LightrailArgumentError
      end
        raise LightrailClient::LightrailArgumentError.new("Invalid transaction_response: #{transaction_response}")
    end

    def self.validate_fund_object! (fund_params)
      begin
        return true if ((fund_params.is_a? Hash) &&
            self.validate_card_id!(fund_params[:cardId]) &&
            self.validate_amount!(fund_params[:amount]) &&
            self.validate_currency!(fund_params[:currency]))
      rescue LightrailClient::LightrailArgumentError
      end
        raise LightrailClient::LightrailArgumentError.new("Invalid fund_params: #{fund_params}")
    end

    def self.validate_ping_response! (ping_response)
      begin
        return true if ((ping_response.is_a? Hash) &&
            (ping_response['user'].is_a? Hash) &&
            !ping_response['user'].empty? &&
            self.validate_username!(ping_response['user']['username']))
      rescue LightrailClient::LightrailArgumentError
      end
        raise LightrailClient::LightrailArgumentError.new("Invalid ping_response: #{ping_response}")
    end


    def self.validate_card_id! (card_id)
      return true if ((card_id.is_a? String) && !card_id.empty?)
      raise LightrailClient::LightrailArgumentError.new("Invalid card_id: #{card_id}")
    end

    def self.validate_code! (code)
      return true if ((code.is_a? String) && !code.empty?)
      raise LightrailClient::LightrailArgumentError.new("Invalid code: #{code}")
    end

    def self.validate_transaction_id! (transaction_id)
      return true if ((transaction_id.is_a? String) && !transaction_id.empty?)
      raise LightrailClient::LightrailArgumentError.new("Invalid transaction_id: #{transaction_id}")
    end

    def self.validate_amount! (amount)
      return true if (amount.is_a? Integer)
      raise LightrailClient::LightrailArgumentError.new("Invalid amount: #{amount}")
    end

    def self.validate_currency! (currency)
      return true if (/\A[A-Z]{3}\z/ === currency)
      raise LightrailClient::LightrailArgumentError.new("Invalid currency: #{currency}")
    end

    def self.validate_username!(username)
      return true if ((username.is_a? String) && !username.empty?)
      raise LightrailClient::LightrailArgumentError.new("Invalid username: #{username}")
    end
  end
end