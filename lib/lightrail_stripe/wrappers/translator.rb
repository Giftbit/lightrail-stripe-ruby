module Lightrail
  class Translator

    def self.translate_charge_params(stripe_style_params)
      lightrail_params = stripe_style_params.clone
      lightrail_params[:value] ||= amount_to_negative_value(stripe_style_params)

      self.translate_transaction_params_except_amount!(lightrail_params)
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

    def self.translate_fund_params(stripe_style_params)
      lightrail_params = stripe_style_params.clone
      lightrail_params[:value] ||= amount_to_positive_value(stripe_style_params)

      self.translate_transaction_params_except_amount!(lightrail_params)
    end

    private

    def self.translate_transaction_params_except_amount!(charge_or_fund_params)
      charge_or_fund_params[:pending] ||= charge_or_fund_params[:capture] === nil ? false : !charge_or_fund_params.delete(:capture)
      charge_or_fund_params[:userSuppliedId] ||= Lightrail::Validator.get_or_create_user_supplied_id(charge_or_fund_params)
      charge_or_fund_params
    end


    def self.amount_to_positive_value(charge_params)
      charge_params[:amount].abs if charge_params[:amount]
    end

    def self.amount_to_negative_value(charge_params)
      -(charge_params[:amount].abs) if charge_params[:amount]
    end
    
  end
end