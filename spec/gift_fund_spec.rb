require "spec_helper"

RSpec.describe LightrailClient::GiftFund do
  subject(:gift_fund) {LightrailClient::GiftFund}

  describe ".create" do
    context "when given valid params" do
      it "funds a gift card with minimum required params" do
        fund_params = {
            amount: 1,
            currency: 'USD',
            cardId: ENV['TEST_CARD_ID'],
        }
        fund_response = gift_fund.create(fund_params)
        expect(fund_response.transactionType).to eq('FUND'), "called GiftFund.create with #{fund_params.inspect}, got back #{fund_response.inspect}"
      end

      it "uses userSuppliedId if supplied in param hash" do
        fund_params = {
            amount: 1,
            currency: 'USD',
            cardId: ENV['TEST_CARD_ID'],
            userSuppliedId: 'test-fund-' + rand().to_s,
        }
        fund_response = gift_fund.create(fund_params)
        expect(fund_response.userSuppliedId).to eq(fund_params[:userSuppliedId]), "called GiftFund.create with #{fund_params.inspect}, got back #{fund_response.inspect}"
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {gift_fund.create()}.to raise_error(ArgumentError), "called GiftFund.create with no params"
        expect {gift_fund.create({})}.to raise_error(LightrailClient::LightrailArgumentError), "called GiftFund.create with empty object"
        expect {gift_fund.create({card: ENV['TEST_CARD_ID']})}.to raise_error(LightrailClient::LightrailArgumentError), "called GiftFund.create with '{card: ENV['TEST_CARD_ID']}'"
        expect {gift_fund.create([])}.to raise_error(LightrailClient::LightrailArgumentError), "called GiftFund.create with empty array"
      end
    end
  end

end