module Lightrail
  class LightrailValue < Lightrail::LightrailObject
    attr_accessor :valueStores, :currency, :cardType, :asAtDate, :cardId

    def self.retrieve_code_details (code)
      Lightrail::Validator.validate_code! (code)
      response = Lightrail::Code.get_details(code)
      self.new(response)
    end

    def self.retrieve_card_details (card_id)
      Lightrail::Validator.validate_card_id!(card_id)
      response = Lightrail::Card.get_details(card_id)
      self.new(response)
    end

    def self.retrieve_contact_account_details (contact_id, currency)
      Lightrail::Validator.validate_contact_id!(contact_id)
      Lightrail::Validator.validate_currency!(currency)
      response = Lightrail::Contact.get_account_details({contact_id: contact_id, currency: currency})
      self.new(response)
    end

    def self.retrieve_by_shopper_id (shopper_id, currency)
      Lightrail::Validator.validate_shopper_id!(shopper_id)
      Lightrail::Validator.validate_currency!(currency)
      response = Lightrail::Contact.get_account_balance_details({shopper_id: shopper_id, currency: currency})
      self.new(response)
    end


    def maximum_value
      maximum_value = 0
      self.valueStores.each do |valueStore|
        if valueStore['state'] == 'ACTIVE'
          maximum_value += valueStore['value']
        end
      end
      maximum_value
    end

  end
end