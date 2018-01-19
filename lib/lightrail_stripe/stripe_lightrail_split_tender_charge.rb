module Lightrail
  class StripeLightrailSplitTenderCharge < Lightrail::LightrailObject
    attr_accessor :lightrail_charge, :stripe_charge, :payment_summary

    def self.create (charge_params, lr_share)
      # Convert to Translator.translate_split_tender_charge_params!()
      Lightrail::SplitTenderValidator.validate_split_tender_charge_params!(charge_params, lr_share)

      total_amount = charge_params[:amount]
      currency = charge_params[:currency]

      stripe_share = total_amount - lr_share

      if lr_share > 0 # start with lightrail charge first
        lightrail_charge_params = Lightrail::Translator.construct_lightrail_pending_charge_params_from_split_tender(charge_params, lr_share)

        lightrail_pending_transaction = Lightrail::LightrailCharge.create(lightrail_charge_params)

        if stripe_share > 0 # continue to stripe charge
          begin
            stripe_params = Lightrail::Translator.charge_params_split_tender_to_stripe(charge_params, stripe_share)
            stripe_transaction = Stripe::Charge.create(stripe_params)
            lightrail_metadata = Lightrail::Translator.construct_lightrail_metadata_for_split_tender_charge(stripe_transaction)
          rescue
            lightrail_pending_transaction.cancel!
            raise $!, "Stripe payment failed: #{$!}", $!.backtrace
          end
        end

        lightrail_captured_transaction = lightrail_pending_transaction.capture!(lightrail_metadata)

      else # all to stripe
        stripe_params = Lightrail::Translator.charge_params_split_tender_to_stripe(charge_params, stripe_share)
        stripe_transaction = Stripe::Charge.create(stripe_params)

      end


      split_tender_charge_payment_summary = {
          total_amount: total_amount,
          currency: currency,
          lightrail_amount: lightrail_captured_transaction ? lightrail_captured_transaction.value : 0,
          stripe_amount: stripe_transaction ? stripe_transaction.amount : 0,
      }

      self.new({lightrail_charge: lightrail_captured_transaction, stripe_charge: stripe_transaction, payment_summary: split_tender_charge_payment_summary})
    end

    def self.create_with_automatic_split (charge_params)
      Lightrail::SplitTenderValidator.validate_split_tender_charge_params!(charge_params)

      split_amounts = self.determine_split!(charge_params)
      lr_share = split_amounts[:lightrail_amount]
      self.create(charge_params, lr_share)
    end

    def self.simulate (charge_params, lr_share)
      Lightrail::SplitTenderValidator.validate_split_tender_charge_params!(charge_params, lr_share)

      total_amount = charge_params[:amount]
      currency = charge_params[:currency]

      stripe_share = total_amount - lr_share

      if lr_share > 0 # only need to simulate Lightrail transaction
        lightrail_charge_params = Lightrail::Translator.construct_lightrail_charge_params_from_split_tender(charge_params, lr_share)

        lightrail_simulated_transaction = Lightrail::LightrailCharge.simulate(lightrail_charge_params)

        lr_final_share = lightrail_simulated_transaction.value
      end

      split_tender_charge_payment_summary = {
          total_amount: total_amount,
          currency: currency,
          lightrail_amount: lr_final_share ? lr_final_share : 0,
          stripe_amount: lr_final_share ? total_amount - lr_final_share.abs : total_amount
      }

      self.new({lightrail_charge: lightrail_simulated_transaction, stripe_charge: nil, payment_summary: split_tender_charge_payment_summary})
    end

    def self.simulate_with_automatic_split (charge_params)
      Lightrail::SplitTenderValidator.validate_split_tender_charge_params!(charge_params)

      split_amounts = self.determine_split!(charge_params)
      lr_share = split_amounts[:lightrail_amount]
      self.simulate(charge_params, lr_share)
    end


    private

    def self.determine_split!(charge_params)
      total_amount = charge_params[:amount]
      contact_id = Lightrail::Contact.get_contact_id_from_id_or_shopper_id(charge_params)
      code = Lightrail::Validator.get_code(charge_params)
      card_id = Lightrail::Validator.get_card_id(charge_params)

      lr_share = if contact_id || code || card_id
                   charge_params_for_simulate = charge_params.clone
                   charge_params_for_simulate[:value] = -charge_params[:amount] || -charge_params['amount']

                   if contact_id
                     Lightrail::Account.simulate_charge(charge_params_for_simulate)['value'].abs
                   elsif code
                     Lightrail::Code.simulate_charge(charge_params_for_simulate)['value'].abs
                   elsif card_id
                     Lightrail::Card.simulate_charge(charge_params_for_simulate)['value'].abs
                   end

                 else
                   nil
                 end

      if lr_share && (lr_share < total_amount) && (Lightrail::SplitTenderValidator.has_stripe_payment_option?(charge_params))
        stripe_share = total_amount - lr_share
        lr_share = stripe_share < 50 ? lr_share - (50-stripe_share) : lr_share
        stripe_share = total_amount - lr_share
      elsif lr_share && (lr_share < total_amount)
        raise Lightrail::BadParameterError.new('Please provide a Stripe payment method to complete the transaction.')
      else
        stripe_share = charge_params[:amount]
      end

      {
          lightrail_amount: lr_share || 0,
          stripe_amount: stripe_share
      }
    end

  end
end