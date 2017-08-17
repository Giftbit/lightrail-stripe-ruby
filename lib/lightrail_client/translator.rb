module LightrailClient
  class Translator

    def self.translate_charge_params(stripe_style_params)
      lightrail_params = stripe_style_params.clone
      lightrail_params[:value] ||= amount_to_negative_value(stripe_style_params)

      self.translate_transaction_params_except_amount!(lightrail_params)
    end

    def self.translate_fund_params(stripe_style_params)
      lightrail_params = stripe_style_params.clone
      lightrail_params[:value] ||= amount_to_positive_value(stripe_style_params)

      self.translate_transaction_params_except_amount!(lightrail_params)
    end

    def self.construct_pending_charge_params_from_hybrid(hybrid_charge_params, lr_share)
      lightrail_params = hybrid_charge_params.clone

      lightrail_params[:pending] = true
      lightrail_params[:value] = -lr_share
      lightrail_params.delete(:amount)

      lightrail_params[:code] ||= self.get_code(lightrail_params)
      lightrail_params[:cardId] ||= self.get_card_id(lightrail_params)

      lightrail_params[:userSuppliedId] ||= self.get_or_create_user_supplied_id(lightrail_params)

      # lightrail_params[:metadata] ||= {hybrid_charge_message: 'This is a hybrid charge'} # TODO figure out real metadata

      lightrail_params
    end

    def self.translate_charge_params_for_stripe(hybrid_charge_params, stripe_share)
      stripe_params = hybrid_charge_params.clone
      stripe_params[:amount] = stripe_share

      # TODO review this closely!
      LightrailClient::Constants::LIGHTRAIL_PAYMENT_METHODS.each {|charge_param_key| stripe_params.delete(charge_param_key)}

      stripe_params
    end


    private

    def self.translate_transaction_params_except_amount!(charge_or_fund_params)
      charge_or_fund_params[:pending] ||= charge_or_fund_params[:capture] === nil ? false : !charge_or_fund_params.delete(:capture)
      charge_or_fund_params[:userSuppliedId] ||= self.get_or_create_user_supplied_id(charge_or_fund_params)
      charge_or_fund_params
    end

    def self.amount_to_positive_value(charge_params)
      charge_params[:amount].abs if charge_params[:amount]
    end

    def self.amount_to_negative_value(charge_params)
      -(charge_params[:amount].abs) if charge_params[:amount]
    end

    def self.capture_to_pending_if_capture(charge_params)
      if !([true, false].include?(charge_params[:pending]))
        charge_params[:capture] === nil ? false : !charge_params[:capture]
      end
    end

    def self.get_card_id(charge_params)
      charge_params[:cardId] ||
          charge_params[:card_id] ||
          charge_params[:lightrail_card_id]
    end

    def self.get_code(charge_params)
      charge_params[:code] ||
          charge_params[:lightrail_code]
    end

    def self.get_code_or_card_id_key(charge_params)
      (charge_params.keys & LightrailClient::Constants::LIGHTRAIL_PAYMENT_METHODS).first
    end

    def self.get_or_create_user_supplied_id(charge_params)
      charge_params[:user_supplied_id] ||
          charge_params[:lightrail_user_supplied_id] ||
          charge_params[:idempotency_key] ||
          SecureRandom::uuid
    end

  end
end