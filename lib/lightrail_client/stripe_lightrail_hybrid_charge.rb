module LightrailClient
  class StripeLightrailHybridCharge < LightrailClient::LightrailObject
    attr_accessor :lightrail_charge, :stripe_charge, :payment_summary

    def self.create (charge_params)
      # Convert to Translator.translate_hybrid_charge_params!()
      LightrailClient::Validator.validate_hybrid_charge_params!(charge_params)

      total_amount = charge_params[:amount]
      currency = charge_params[:currency]

      lr_payment_param_key = LightrailClient::Translator.get_code_or_card_id_key(charge_params)
      lr_share = lr_payment_param_key ? self.determine_lightrail_share!(charge_params) : 0

      if LightrailClient::Validator.has_stripe_payment_option?(charge_params)
        stripe_share = total_amount - lr_share
      elsif (lr_share < total_amount)
        raise LightrailClient::InsufficientValueError.new('Gift card value not sufficient to cover total amount. Please provide a credit card.')
      else
        stripe_share = 0
      end


      if lr_share > 0 # start with lightrail charge first
        lightrail_charge_params = LightrailClient::Translator.construct_pending_charge_params_from_hybrid(charge_params, lr_share)

        lightrail_pending_transaction = LightrailClient::LightrailCharge.create(lightrail_charge_params)

        if stripe_share > 0 # continue to stripe charge
          begin
            stripe_params = LightrailClient::Translator.translate_charge_params_for_stripe(charge_params, stripe_share)
            stripe_transaction = Stripe::Charge.create(stripe_params)
          rescue
            LightrailClient::LightrailCharge.cancel(lightrail_pending_transaction)
            raise $!, "Stripe payment failed: #{$!}", $!.backtrace
          end
        end

        lightrail_captured_transaction = LightrailClient::LightrailCharge.capture(lightrail_pending_transaction)

      else # all to stripe
        stripe_params = LightrailClient::Translator.translate_charge_params_for_stripe(charge_params, stripe_share)
        stripe_transaction = Stripe::Charge.create(stripe_params)

      end


      hybrid_charge_payment_summary = {
          total_amount: total_amount,
          currency: currency,
          lightrail_amount: lightrail_captured_transaction.value,
          stripe_amount: stripe_transaction.amount,
      }

      self.new({lightrail_charge: lightrail_captured_transaction, stripe_charge: stripe_transaction, payment_summary: hybrid_charge_payment_summary})
    end


    private

    def self.determine_lightrail_share!(charge_params)
      code = LightrailClient::Translator.get_code(charge_params)
      card_id = LightrailClient::Translator.get_card_id(charge_params)

      lightrail_balance = if code
                            LightrailClient::LightrailValue.retrieve_by_code(code)
                          elsif card_id
                            LightrailClient::LightrailValue.retrieve_by_card_id(card_id)
                          else
                            raise LightrailClient::LightrailArgumentError.new('A valid Lightrail code or cardId is required for a balance check.')
                          end

      [charge_params[:amount], lightrail_balance.total_available].min
    end

  end
end