require "spec_helper"

RSpec.describe LightrailClientRuby::Refund do
  subject(:refund) {LightrailClientRuby::Refund}

  describe ".create" do

    context "when given valid params" do
      it "refunds a transaction" do
        charge_object = {
            amount: 1,
            currency: 'USD',
            code: ENV['TEST_CODE'],
            capture: true,
        }
        charge = LightrailClientRuby::GiftCharge.create(charge_object)
        refund_response = refund.create(charge)
        expect(refund_response.transactionType).to eq('DRAWDOWN_REFUND')
        expect(refund_response.parentTransactionId).to eq(charge.transactionId)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {refund.create()}.to raise_error(ArgumentError), "called Refund.create with no params"
        expect {refund.create({})}.to raise_error(LightrailClientRuby::LightrailArgumentError), "called Refund.create with empty object"
        expect {refund.create({card: ENV['TEST_CARD_ID']})}.to raise_error(LightrailClientRuby::LightrailArgumentError), "called Refund.create with '{card: ENV['TEST_CARD_ID']}'"
        expect {refund.create([])}.to raise_error(LightrailClientRuby::LightrailArgumentError), "called Refund.create with empty array"
      end
    end

  end
end