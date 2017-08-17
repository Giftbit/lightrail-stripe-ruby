module LightrailClient
  class Validator
    def self.validate_charge_object! (charge_params)
      begin
        return true if ((charge_params.is_a? Hash) &&
            (self.has_valid_code?(charge_params) || self.has_valid_card_id?(charge_params)) &&
            self.validate_amount!(charge_params[:amount] || charge_params[:value]) &&
            self.validate_currency!(charge_params[:currency]))
      rescue LightrailClient::LightrailArgumentError
      end
      raise LightrailClient::LightrailArgumentError.new("Invalid charge_params: #{charge_params.inspect}")
    end

    def self.validate_hybrid_charge_params! (hybrid_charge_params)
      begin
        return true if ((hybrid_charge_params.is_a? Hash) &&
            self.validate_amount!(hybrid_charge_params[:amount]) &&
            self.validate_currency!(hybrid_charge_params[:currency]) &&
            (self.has_lightrail_payment_option?(hybrid_charge_params) ||
                self.has_stripe_payment_option?(hybrid_charge_params)))
      rescue LightrailClient::LightrailArgumentError
      end
      raise LightrailClient::LightrailArgumentError.new("Invalid hybrid_charge_params: #{hybrid_charge_params.inspect}")
    end

    def self.validate_transaction_response! (transaction_response)
      begin
        return true if (transaction_response.is_a? LightrailClient::LightrailCharge) && transaction_response.transactionId && transaction_response.cardId
      rescue LightrailClient::LightrailArgumentError
      end
      raise LightrailClient::LightrailArgumentError.new("Invalid transaction_response: #{transaction_response.inspect}")
    end

    def self.validate_fund_object! (fund_params)
      begin
        return true if ((fund_params.is_a? Hash) &&
            self.validate_card_id!(fund_params[:cardId]) &&
            self.validate_amount!(fund_params[:amount]) &&
            self.validate_currency!(fund_params[:currency]))
      rescue LightrailClient::LightrailArgumentError
      end
      raise LightrailClient::LightrailArgumentError.new("Invalid fund_params: #{fund_params.inspect}")
    end

    def self.validate_ping_response! (ping_response)
      begin
        return true if ((ping_response.is_a? Hash) &&
            (ping_response['user'].is_a? Hash) &&
            !ping_response['user'].empty? &&
            self.validate_username!(ping_response['user']['username']))
      rescue LightrailClient::LightrailArgumentError
      end
      raise LightrailClient::LightrailArgumentError.new("Invalid ping_response: #{ping_response.inspect}")
    end


    def self.validate_card_id! (card_id)
      return true if ((card_id.is_a? String) && (/\A[A-Z0-9\-]+\z/i =~ card_id))
      raise LightrailClient::LightrailArgumentError.new("Invalid card_id: #{card_id.inspect}")
    end

    def self.validate_code! (code)
      return true if ((code.is_a? String) && (/\A[A-Z0-9\-]+\z/i =~ code))
      raise LightrailClient::LightrailArgumentError.new("Invalid code: #{code.inspect}")
    end

    def self.validate_transaction_id! (transaction_id)
      return true if ((transaction_id.is_a? String) && !transaction_id.empty?)
      raise LightrailClient::LightrailArgumentError.new("Invalid transaction_id: #{transaction_id.inspect}")
    end

    def self.validate_amount! (amount)
      return true if (amount.is_a? Integer)
      raise LightrailClient::LightrailArgumentError.new("Invalid amount: #{amount.inspect}")
    end

    def self.validate_currency! (currency)
      return true if (/\A[A-Z]{3}\z/ === currency)
      raise LightrailClient::LightrailArgumentError.new("Invalid currency: #{currency.inspect}")
    end

    def self.validate_username!(username)
      return true if ((username.is_a? String) && !username.empty?)
      raise LightrailClient::LightrailArgumentError.new("Invalid username: #{username.inspect}")
    end

    private

    def self.has_valid_code?(charge_params)
      code = LightrailClient::Translator.get_code(charge_params)
      code && self.validate_code!(charge_params[:code])
    end

    def self.has_valid_card_id?(charge_params)
      cardId = LightrailClient::Translator.get_card_id(charge_params)
      cardId && self.validate_card_id!(charge_params[:cardId])
    end

    def self.has_lightrail_payment_option?(charge_params)
      (self.has_valid_code?(charge_params) || self.has_valid_card_id?(charge_params))
    end

    def self.has_stripe_payment_option?(charge_params)
      charge_params.has_key?(:source) || charge_params.has_key?(:customer)
    end

  end
end