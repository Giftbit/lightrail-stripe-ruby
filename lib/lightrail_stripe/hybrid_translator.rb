module Lightrail
  class HybridTranslator < Lightrail::Translator

    def self.construct_pending_charge_params_from_hybrid(hybrid_charge_params, lr_share)
      lightrail_params = hybrid_charge_params.clone

      lightrail_params[:pending] = true
      lightrail_params[:value] = -lr_share
      lightrail_params.delete(:amount)

      lightrail_params[:code] ||= Lightrail::Validator.get_code(lightrail_params)
      lightrail_params[:cardId] ||= Lightrail::Validator.get_card_id(lightrail_params)

      lightrail_params[:userSuppliedId] ||= Lightrail::Validator.get_or_create_user_supplied_id(lightrail_params)

      lightrail_params
    end

    def self.translate_charge_params_for_stripe(hybrid_charge_params, stripe_share)
      stripe_params = hybrid_charge_params.clone
      stripe_params[:amount] = stripe_share

      Lightrail::Constants::LIGHTRAIL_PAYMENT_METHODS.each {|charge_param_key| stripe_params.delete(charge_param_key)}

      stripe_params
    end

    def self.construct_lightrail_metadata_for_hybrid_charge(stripe_transaction)
      {
          metadata: {
              hybridChargeDetails: {
                  stripeTransactionId: stripe_transaction.id
              }
          }
      }
    end

  end
end