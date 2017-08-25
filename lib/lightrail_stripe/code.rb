module Lightrail
  class Code

    def self.charge(charge_params)
      Lightrail::Transaction.charge_code(charge_params)
    end

    def self.get_balance_details(code)
      Lightrail::Connection.get_balance_details(:code, code)
    end

    def self.get_total_balance(code)
      balance_details = self.get_balance_details(code)
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