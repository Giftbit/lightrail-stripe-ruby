require "spec_helper"

RSpec.describe LightrailClientRuby::GiftFund do
  subject(:gift_fund) {LightrailClientRuby::GiftFund}

  describe ".create" do
    context "when given valid params" do
      it "funds a gift card with minimum required params" do
        fund_object = {
            amount: 1,
            currency: 'USD',
            cardId: ENV['TEST_CARD_ID'],
        }
        fund_response = gift_fund.create(fund_object)
        expect(fund_response['transaction']['transactionType']).to eq('FUND'), "called GiftFund.create with #{fund_object}, got back #{fund_response}"
      end

      it "uses userSuppliedId if supplied in param hash" do
        fund_object = {
            amount: 1,
            currency: 'USD',
            cardId: ENV['TEST_CARD_ID'],
            userSuppliedId: 'test-fund-' + rand().to_s,
        }
        fund_response = gift_fund.create(fund_object)
        expect(fund_response['transaction']['userSuppliedId']).to eq(fund_object[:userSuppliedId]), "called GiftFund.create with #{fund_object}, got back #{fund_response}"
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {gift_fund.create()}.to raise_error(ArgumentError), "called GiftFund.create with no params"
        expect {gift_fund.create({})}.to raise_error(ArgumentError), "called GiftFund.create with empty object"
        expect {gift_fund.create({card: ENV['TEST_CARD_ID']})}.to raise_error(ArgumentError), "called GiftFund.create with '{card: ENV['TEST_CARD_ID']}'"
        expect {gift_fund.create([])}.to raise_error(ArgumentError), "called GiftFund.create with empty array"
      end
    end
  end

end