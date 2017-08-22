module Lightrail
  class StripeLightrailHybridCharge < Lightrail::LightrailObject
    attr_accessor :lightrail_charge, :stripe_charge, :payment_summary

    def self.create (charge_params)
      # Convert to Translator.translate_hybrid_charge_params!()
      Lightrail::Validator.validate_hybrid_charge_params!(charge_params)

      total_amount = charge_params[:amount]
      currency = charge_params[:currency]

      split_amounts = self.determine_split!(charge_params)
      lr_share = split_amounts[:lightrail_amount]
      stripe_share = split_amounts[:stripe_amount]

      if lr_share > 0 # start with lightrail charge first
        lightrail_charge_params = Lightrail::Translator.construct_pending_charge_params_from_hybrid(charge_params, lr_share)

        lightrail_pending_transaction = Lightrail::LightrailCharge.create(lightrail_charge_params)

        if stripe_share > 0 # continue to stripe charge
          begin
            stripe_params = Lightrail::Translator.translate_charge_params_for_stripe(charge_params, stripe_share)
            stripe_transaction = Stripe::Charge.create(stripe_params)
            lightrail_metadata = Lightrail::Translator.construct_lightrail_metadata_for_hybrid_charge(stripe_transaction)
          rescue
            Lightrail::LightrailCharge.cancel(lightrail_pending_transaction)
            raise $!, "Stripe payment failed: #{$!}", $!.backtrace
          end
        end

        lightrail_captured_transaction = Lightrail::LightrailCharge.capture(lightrail_pending_transaction, lightrail_metadata)

      else # all to stripe
        stripe_params = Lightrail::Translator.translate_charge_params_for_stripe(charge_params, stripe_share)
        stripe_transaction = Stripe::Charge.create(stripe_params)

      end


      hybrid_charge_payment_summary = {
          total_amount: total_amount,
          currency: currency,
          lightrail_amount: lightrail_captured_transaction ? lightrail_captured_transaction.value : 0,
          stripe_amount: stripe_transaction ? stripe_transaction.amount : 0,
      }

      self.new({lightrail_charge: lightrail_captured_transaction, stripe_charge: stripe_transaction, payment_summary: hybrid_charge_payment_summary})
    end


    private

    def self.determine_split!(charge_params)
      total_amount = charge_params[:amount]
      code = Lightrail::Translator.get_code(charge_params)
      card_id = Lightrail::Translator.get_card_id(charge_params)

      lightrail_balance = if code
                            Lightrail::LightrailValue.retrieve_by_code(code)
                          elsif card_id
                            Lightrail::LightrailValue.retrieve_by_card_id(card_id)
                          else
                            nil
                          end

      lr_share = lightrail_balance ? [total_amount, lightrail_balance.total_available].min : 0

      if (lr_share < total_amount) && (Lightrail::Validator.has_stripe_payment_option?(charge_params))
        stripe_share = total_amount - lr_share
        lr_share = stripe_share < 50 ? lr_share - (50-stripe_share) : lr_share
        stripe_share = total_amount - lr_share
      elsif (lr_share < total_amount)
        raise Lightrail::InsufficientValueError.new('Gift card value not sufficient to cover total amount. Please provide a credit card.')
      else
        stripe_share = 0
      end

      {
          lightrail_amount: lr_share,
          stripe_amount: stripe_share
      }
    end

  end
end