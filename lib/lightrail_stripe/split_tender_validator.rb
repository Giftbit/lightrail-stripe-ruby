module Lightrail
  class SplitTenderValidator < Lightrail::Validator

    def self.validate_split_tender_charge_params! (split_tender_charge_params)
      begin
        return true if ((split_tender_charge_params.is_a? Hash) &&
            Lightrail::Validator.validate_amount!(split_tender_charge_params[:amount]) &&
            Lightrail::Validator.validate_currency!(split_tender_charge_params[:currency]) &&
            (Lightrail::Validator.has_lightrail_payment_option?(split_tender_charge_params) ||
                self.has_stripe_payment_option?(split_tender_charge_params)))
      rescue Lightrail::LightrailArgumentError
      end
      raise Lightrail::LightrailArgumentError.new("Invalid split_tender_charge_params: #{split_tender_charge_params.inspect}")
    end

    def self.has_stripe_payment_option?(charge_params)
      charge_params.has_key?(:source) || charge_params.has_key?(:customer)
    end

  end
end