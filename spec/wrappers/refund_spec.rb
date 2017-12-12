require "spec_helper"

RSpec.describe Lightrail::Refund do
  subject(:refund) {Lightrail::Refund}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_transaction_id) {'this-is-a-transaction-id'}

  let(:charge_object) {Lightrail::LightrailCharge.new({
                                                          transactionId: example_transaction_id,
                                                          value: -5,
                                                          userSuppliedId: 'abc123def456xxx',
                                                          transactionType: 'DRAWDOWN',
                                                          cardId: example_card_id,
                                                          currency: 'USD'
                                                      })}

  describe ".create" do

    context "when given valid params" do
      it "refunds a transaction" do
        expect(lightrail_connection).
            to receive(:make_post_request_and_parse_response).
                with(/cards\/#{charge_object.cardId}\/transactions\/#{charge_object.transactionId}\/refund/, Hash).
                and_return({"transaction" => {}})

        refund_obj = refund.create(charge_object)
        expect(refund_obj).to be_a(refund)
      end

      it "uses the userSuppliedId if provided" do
        expect(lightrail_connection).
            to receive(:make_post_request_and_parse_response).
                with(/cards\/#{charge_object.cardId}\/transactions\/#{charge_object.transactionId}\/refund/, hash_including(userSuppliedId: 'use-this-user-supplied-id')).
                and_return({"transaction" => {}})

        refund.create(charge_object, {userSuppliedId: 'use-this-user-supplied-id'})
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {refund.create()}.to raise_error(ArgumentError), "called Refund.create with no params"
        expect {refund.create({})}.to raise_error(Lightrail::LightrailArgumentError), "called Refund.create with empty object"
        expect {refund.create({card: example_card_id})}.to raise_error(Lightrail::LightrailArgumentError), "called Refund.create with '{card: 'example_card_id'}'"
        expect {refund.create([])}.to raise_error(Lightrail::LightrailArgumentError), "called Refund.create with empty array"
      end
    end

  end
end