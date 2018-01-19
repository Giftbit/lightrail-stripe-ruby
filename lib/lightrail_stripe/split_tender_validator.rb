module Lightrail
  class SplitTenderValidator < Lightrail::Validator

    def self.validate_split_tender_charge_params! (split_tender_charge_params, lr_share=0)

      raise Lightrail::LightrailArgumentError.new("Invalid split_tender_charge_params - must be a hash: #{split_tender_charge_params.inspect}") unless (split_tender_charge_params.is_a? Hash)

      raise Lightrail::LightrailArgumentError.new("Invalid amount in split_tender_charge_params: #{split_tender_charge_params.inspect}") unless Lightrail::Validator.validate_amount!(split_tender_charge_params[:amount])

      raise Lightrail::LightrailArgumentError.new("Amount in split_tender_charge_params less than specified Lightrail share of #{lr_share}: #{split_tender_charge_params.inspect}") unless (split_tender_charge_params[:amount] >= lr_share)

      raise Lightrail::LightrailArgumentError.new("Invalid currency in split_tender_charge_params: #{split_tender_charge_params.inspect}") unless Lightrail::Validator.validate_currency!(split_tender_charge_params[:currency])

      raise Lightrail::LightrailArgumentError.new("Must provide a payment method for either Lightrail or Stripe: #{split_tender_charge_params.inspect}") unless (self.has_lightrail_payment_option?(split_tender_charge_params) || self.has_stripe_payment_option?(split_tender_charge_params))

      return true
    end

    def self.has_stripe_payment_option?(charge_params)
      charge_params.has_key?(:source) || charge_params.has_key?(:customer)
    end

    def self.has_lightrail_payment_option?(charge_params)
      Lightrail::Validator.has_valid_code?(charge_params) ||
          Lightrail::Validator.has_valid_card_id?(charge_params) ||
          Lightrail::Validator.has_valid_contact_id?(charge_params) ||
          Lightrail::Validator.has_valid_shopper_id?(charge_params)
    end

  end
end