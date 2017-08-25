module Lightrail
  class Card < Lightrail::LightrailObject

    def self.charge(charge_params)
      Lightrail::Transaction.charge_card(charge_params)
    end

    def self.fund(fund_params)
      Lightrail::Transaction.fund_card(fund_params)
    end

    def self.get_balance_details(card_id)
      Lightrail::Connection.get_balance_details(:cardId, card_id)
    end

    def self.get_total_balance(card_id)
      balance_details = self.get_balance_details(card_id)
      total = balance_details['principal']['currentValue']
      balance_details['attached'].reduce(total) do |sum, valueStore|
        if valueStore['state'] == "ACTIVE"
          total += valueStore['currentValue']
        end
      end
      total
    end

  end
end