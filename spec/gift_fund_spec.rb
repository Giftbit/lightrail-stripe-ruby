require "spec_helper"

RSpec.describe LightrailClientRuby::GiftFund do

  describe ".create" do
    it "funds a gift card" do
      fund_object = {
          amount: 1,
          currency: 'USD',
          userSuppliedId: 'ruby-fund-test-' + rand().to_s,
          cardId: ENV['TEST_CARD'],
      }
      fund_response = LightrailClientRuby::GiftFund.create(fund_object)
      expect(fund_response['transaction']['transactionType']).to eq('FUND')
    end
  end

end