module Lightrail
  class Translator

    def self.charge_params_stripe_to_lightrail(stripe_style_params)
      self.stripe_params_to_lightrail!(stripe_style_params, true)
    end

    def self.charge_instance_to_hash!(charge_instance)
      if charge_instance.is_a? Lightrail::LightrailCharge
        charge_hash = {}
        charge_instance.instance_variables.each {|instance_variable| charge_hash[instance_variable.to_s.delete('@')] = charge_instance.instance_variable_get(instance_variable)}
        charge_hash
      else
        raise Lightrail::LightrailArgumentError.new("Translator.charge_instance_to_hash! received #{charge_instance.inspect}")
      end
    end

    def self.fund_params_stripe_to_lightrail(stripe_style_params)
      self.stripe_params_to_lightrail!(stripe_style_params, false)
    end

    def self.construct_lightrail_charge_params_from_split_tender(split_tender_charge_params, lr_share)
      lightrail_params = split_tender_charge_params.clone

      lightrail_params[:pending] ||= lightrail_params[:capture] === nil ? false : !lightrail_params.delete(:capture)
      lightrail_params[:value] = -lr_share
      lightrail_params.delete(:amount)

      lightrail_params[:contact_id] ||= Lightrail::Validator.get_contact_id(lightrail_params)
      lightrail_params[:shopper_id] ||= Lightrail::Validator.get_shopper_id(lightrail_params)
      if (lightrail_params[:contact_id] || lightrail_params[:shopper_id])
        lightrail_params = Lightrail::Account.replace_contact_id_or_shopper_id_with_card_id(lightrail_params)
      end

      lightrail_params[:code] ||= Lightrail::Validator.get_code(lightrail_params)
      lightrail_params[:cardId] ||= Lightrail::Validator.get_card_id(lightrail_params)

      lightrail_params[:userSuppliedId] ||= Lightrail::Validator.get_or_create_user_supplied_id(lightrail_params)

      lightrail_params
    end

    def self.construct_lightrail_pending_charge_params_from_split_tender(split_tender_charge_params, lr_share)
      lightrail_params = self.construct_lightrail_charge_params_from_split_tender(split_tender_charge_params, lr_share)
      lightrail_params[:pending] = true

      lightrail_params
    end

    def self.charge_params_split_tender_to_stripe(split_tender_charge_params, stripe_share)
      stripe_params = split_tender_charge_params.clone
      stripe_params[:amount] = stripe_share

      Lightrail::Constants::LIGHTRAIL_PAYMENT_METHODS.each {|charge_param_key| stripe_params.delete(charge_param_key)}
      Lightrail::Constants::LIGHTRAIL_USER_SUPPLIED_ID_KEYS.each {|supplied_id_key| stripe_params.delete(supplied_id_key)}

      stripe_params
    end

    def self.construct_lightrail_metadata_for_split_tender_charge(stripe_transaction)
      {
          metadata: {
              splitTenderChargeDetails: {
                  stripeTransactionId: stripe_transaction.id
              }
          }
      }
    end

    private

    def self.stripe_params_to_lightrail!(transaction_params, convert_amount_to_negative_value)
      lr_transaction_params = transaction_params.clone
      lr_transaction_params[:pending] ||= lr_transaction_params[:capture] === nil ? false : !lr_transaction_params.delete(:capture)
      lr_transaction_params[:userSuppliedId] ||= Lightrail::Validator.get_or_create_user_supplied_id(lr_transaction_params)
      lr_transaction_params[:value] ||= convert_amount_to_negative_value ? -(lr_transaction_params[:amount].abs) : lr_transaction_params[:amount].abs

      if (Lightrail::Validator.has_valid_contact_id?(lr_transaction_params) || Lightrail::Validator.has_valid_shopper_id?(lr_transaction_params))
        lr_transaction_params = Lightrail::Account.replace_contact_id_or_shopper_id_with_card_id(lr_transaction_params)
      end

      lr_transaction_params
    end

  end
end