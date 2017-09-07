require "spec_helper"

RSpec.describe Lightrail::LightrailFund do
  subject(:lightrail_fund) {Lightrail::LightrailFund}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:fund_params) {{
      amount: 1,
      currency: 'USD',
      cardId: 'this-is-a-card-id',
      userSuppliedId: '123-abc-456-def',
  }}

  describe ".create" do
    context "when given valid params" do
      before(:each) do
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{fund_params[:cardId]}\/transactions/, hash_including({userSuppliedId: fund_params[:userSuppliedId]})).and_return({"transaction" => {}})
      end

      it "funds a gift card with minimum required params" do
        lightrail_fund.create(fund_params)
      end

      it "uses userSuppliedId if supplied in param hash" do
        lightrail_fund.create(fund_params)
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