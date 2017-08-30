module Lightrail
  class HybridValidator < Lightrail::Validator

    def self.validate_hybrid_charge_params! (hybrid_charge_params)
      begin
        return true if ((hybrid_charge_params.is_a? Hash) &&
            Lightrail::Validator.validate_amount!(hybrid_charge_params[:amount]) &&
            Lightrail::Validator.validate_currency!(hybrid_charge_params[:currency]) &&
            (Lightrail::Validator.has_lightrail_payment_option?(hybrid_charge_params) ||
                self.has_stripe_payment_option?(hybrid_charge_params)))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid hybrid_charge_params: #{hybrid_charge_params.inspect}")
    end

    def self.has_stripe_payment_option?(charge_params)
      charge_params.has_key?(:source) || charge_params.has_key?(:customer)
    end

  end
end