require "spec_helper"

RSpec.describe Lightrail::LightrailFund do
  subject(:lightrail_fund) {Lightrail::LightrailFund}

  describe ".create" do
    context "when given valid params" do
      it "funds a gift card with minimum required params" do
        fund_params = {
            amount: 1,
            currency: 'USD',
            cardId: ENV['LIGHTRAIL_TEST_CARD_ID'],
        }
        fund_response = lightrail_fund.create(fund_params)
        expect(fund_response.transactionType).to eq('FUND'), "called LightrailFund.create with #{fund_params.inspect}, got back #{fund_response.inspect}"
      end

      it "uses userSuppliedId if supplied in param hash" do
        fund_params = {
            amount: 1,
            currency: 'USD',
            cardId: ENV['LIGHTRAIL_TEST_CARD_ID'],
            userSuppliedId: 'test-fund-' + rand().to_s,
        }
        fund_response = lightrail_fund.create(fund_params)
        expect(fund_response.userSuppliedId).to eq(fund_params[:userSuppliedId]), "called LightrailFund.create with #{fund_params.inspect}, got back #{fund_response.inspect}"
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_fund.create()}.to raise_error(ArgumentError), "called LightrailFund.create with no params"
        expect {lightrail_fund.create({})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailFund.create with empty object"
        expect {lightrail_fund.create({card: ENV['LIGHTRAIL_TEST_CARD_ID']})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailFund.create with '{card: ENV['LIGHTRAIL_TEST_CARD_ID']}'"
        expect {lightrail_fund.create([])}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailFund.create with empty array"
      end
    end
  end

end