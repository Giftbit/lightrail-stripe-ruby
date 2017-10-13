module Lightrail
  class LightrailValue < Lightrail::LightrailObject
    attr_accessor :principal, :attached, :currency, :cardType, :balanceDate, :cardId

    def self.retrieve_by_code (code)
      Lightrail::Validator.validate_code! (code)
      response = Lightrail::Code.get_balance_details(code)
      self.new(response)
    end

    def self.retrieve_by_card_id (card_id)
      Lightrail::Validator.validate_card_id!(card_id)
      response = Lightrail::Card.get_balance_details(card_id)
      self.new(response)
    end


    def total_available
      total = self.principal['currentValue']
      self.attached.reduce(total) do |sum, valueStore|
        if valueStore['state'] == "ACTIVE"
          total += valueStore['currentValue']
        end
      end
      total
    end

  end
end