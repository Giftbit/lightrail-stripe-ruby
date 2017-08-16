module LightrailClient
  class Translator

    def self.translate (stripe_object, is_value_positive=false)
      lightrail_object = stripe_object.clone
      lightrail_object[:value] ||= lightrail_object.delete(:amount) if lightrail_object[:amount]
      lightrail_object[:pending] ||= lightrail_object[:capture] === nil ? false : !lightrail_object.delete(:capture)
      lightrail_object[:userSuppliedId] ||= SecureRandom::uuid

      lightrail_object[:value] && is_value_positive ? lightrail_object[:value] = lightrail_object[:value].abs : lightrail_object[:value] = -lightrail_object[:value].abs

      lightrail_object
    end

    def self.construct_pending_charge_params_from_hybrid(hybrid_charge_params, lr_share)
      lightrail_params = hybrid_charge_params.clone

      lightrail_params[:pending] = true
      lightrail_params[:value] = -lr_share
      lightrail_params.delete(:amount)

      lightrail_params[:code] ||= self.get_code(lightrail_params)
      lightrail_params[:cardId] ||= self.get_card_id(lightrail_params)

      lightrail_params[:userSuppliedId] ||= self.user_supplied_id_translate_or_create(lightrail_params)

      # lightrail_params[:metadata] ||= {hybrid_charge_message: 'This is a hybrid charge'} # TODO figure out real metadata

      lightrail_params
    end


    private

    def self.amount_to_positive_value(charge_params)
      charge_params[:amount].abs if charge_params[:amount]
    end

    def self.amount_to_negative_value(charge_params)
      -(charge_params[:amount].abs) if charge_params[:amount]
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
      (charge_params.keys & [:code, :lightrail_code, :cardId, :card_id, :lightrail_card_id]).first
    end

    def self.user_supplied_id_translate_or_create(charge_params)
      charge_params[:user_supplied_id] ||
          charge_params[:lightrail_user_supplied_id] ||
          charge_params[:idempotency_key] ||
          SecureRandom::uuid
    end

  end
end