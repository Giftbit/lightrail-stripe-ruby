require "spec_helper"

RSpec.describe LightrailClientRuby::Refund do

  describe ".create" do
    it "refunds a transaction" do
      charge_object = {
          amount: 1,
          currency: 'USD',
          code: ENV['TEST_CODE'],
          capture: true,
      }
      transaction_object = LightrailClientRuby::GiftCharge.create(charge_object)
      refund_response = LightrailClientRuby::Refund.create(transaction_object)
      expect(refund_response['transaction']['transactionType']).to eq('DRAWDOWN_REFUND')
    end
  end

end