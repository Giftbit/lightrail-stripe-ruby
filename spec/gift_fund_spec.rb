require "spec_helper"

RSpec.describe LightrailClientRuby::GiftFund do

  describe ".create" do
    context "when given valid params" do
      it "funds a gift card with minimum required params" do
        fund_object = {
            amount: 1,
            currency: 'USD',
            cardId: ENV['TEST_CARD'],
        }
        fund_response = LightrailClientRuby::GiftFund.create(fund_object)
        expect(fund_response['transaction']['transactionType']).to eq('FUND')
      end

      it "uses userSuppliedId if supplied in param hash" do
        fund_object = {
            amount: 1,
            currency: 'USD',
            code: ENV['TEST_CODE'],
            userSuppliedId: 'test-fund-' + rand().to_s,
        }
        fund_response = LightrailClientRuby::GiftCharge.create(fund_object)
        expect(fund_response['transaction']['userSuppliedId']).to eq(fund_object[:userSuppliedId])
      end
    end
  end

end