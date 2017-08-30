require "spec_helper"

RSpec.describe Lightrail::Refund do
  subject(:refund) {Lightrail::Refund}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:charge_object_details) {{
      cardId: 'card-123456',
      codeLastFour: 'TEST',
      currency: 'USD',
      transactionId: 'transaction-123456',
      transactionType: 'DRAWDOWN',
      userSuppliedId: '123-abc-456-def',
      value: -1,
  }}

  describe ".create" do

    context "when given valid params" do
      it "refunds a transaction" do
        charge = Lightrail::LightrailCharge.new(charge_object_details)

        expect(lightrail_connection).
            to receive(:make_post_request_and_parse_response).
                with(/cards\/#{charge.cardId}\/transactions\/#{charge.transactionId}\/refund/, Hash).
                and_return({"transaction" => {}})

        refund.create(charge)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {refund.create()}.to raise_error(ArgumentError), "called Refund.create with no params"
        expect {refund.create({})}.to raise_error(Lightrail::LightrailArgumentError), "called Refund.create with empty object"
        expect {refund.create({card: ENV['LIGHTRAIL_TEST_CARD_ID']})}.to raise_error(Lightrail::LightrailArgumentError), "called Refund.create with '{card: ENV['LIGHTRAIL_TEST_CARD_ID']}'"
        expect {refund.create([])}.to raise_error(Lightrail::LightrailArgumentError), "called Refund.create with empty array"
      end
    end

  end
end