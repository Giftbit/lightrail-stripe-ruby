module LightrailClient
  class StripeLightrailHybridCharge < LightrailClient::LightrailObject
    attr_accessor :lightrail_charge, :stripe_charge, :payment_summary

    def self.create (charge_params)
      # # validate params: require amount, currency, lr OR stripe source
      # # eg:
      # LightrailClient::Validator.validate_hybrid_charge_object!(charge_params)

      total_amount = charge_params[:amount]
      currency = charge_params[:currency]

      lr_share = (self.determine_lightrail_share(charge_params) if self.has_lightrail_payment_option?(charge_params)).to_i

      if self.has_stripe_payment_option?(charge_params)
        stripe_share = total_amount - lr_share
      elsif (lr_share < total_amount)
        raise LightrailClient::InsufficientValueError.new("Gift card value not sufficient to cover total amount. Please provide a credit card.")
      else
        stripe_share = 0
      end

      # # if lr_share > 0: set up lr charge
      if lr_share > 0
        lightrail_charge_params = charge_params.clone
        lightrail_charge_params[:amount] = lr_share
        lightrail_charge_params[:capture] = false
        lightrail_charge_params[:metadata] = {hybrid_charge_message: 'This is a hybrid charge'} # TODO figure out real metadata

        lightrail_pending_transaction = LightrailClient::LightrailCharge.create(lightrail_charge_params)

        if stripe_share > 0
          begin
            stripe_charge_params = {
                amount: stripe_share,
                currency: currency,
                source: charge_params[:stripe_source]
            } # add other stripe params - idempotency, etc
            stripe_transaction = Stripe::Charge.create(stripe_charge_params)
          rescue # TODO decide which error responses to handle
            LightrailClient::LightrailCharge.cancel(lightrail_pending_transaction)
            raise LightrailClient::ThirdPartyPaymentError.new("Stripe payment failed", stripe_transaction)
          end

          lightrail_captured_transaction = LightrailClient::LightrailCharge.capture(lightrail_pending_transaction)
        end

        # # else charge all to stripe (catch error throw ThirdPartyPaymentError)
      else # all to stripe
        stripe_charge_params = {
            amount: stripe_share,
            currency: currency,
            source: charge_params[:stripe_source]
        } # add other stripe params - source, idempotency, etc
        stripe_transaction = Stripe::Charge.create(stripe_charge_params)
      end


      # # produce payment_summary (lr amount & info incl metadata, stripe amount & info)
      # # return LRSHybridCharge(lr_charge, str_charge, payment_summary)

      self.new({lightrail_charge: lightrail_captured_transaction, stripe_charge: stripe_transaction})
    end


    private

    def self.has_lightrail_payment_option?(charge_params)
      !!charge_params.keys.detect { |param| param =~ /lightrail/ }
    end

    def self.has_stripe_payment_option?(charge_params)
      !!charge_params.keys.detect { |param| param =~ /stripe/ }
    end

    def self.determine_lightrail_share(charge_params)
      lightrail_balance = LightrailClient::LightrailValue.retrieve(charge_params[:code])
      [charge_params[:amount], lightrail_balance.total_available].min
    end

  end
end