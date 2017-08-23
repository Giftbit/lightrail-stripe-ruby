require "spec_helper"

RSpec.describe Lightrail::Transaction do
  subject(:transaction) {Lightrail::Transaction}

  describe ".create" do
    it "posts a new drawdown transaction to a code" do
      charge_params = {
          value: -1,
          currency: 'USD',
          code: ENV['LIGHTRAIL_TEST_CODE'],
      }
      transac = transaction.create(charge_params, :code_drawdown)
      expect(transac).to have_key('transactionId')
    end

    it "posts a new drawdown transaction to a card ID" do
      charge_params = {
          value: -1,
          currency: 'USD',
          card_id: ENV['LIGHTRAIL_TEST_CARD_ID'],
      }
      transac = transaction.create(charge_params, :card_id_drawdown)
      expect(transac).to have_key('transactionId')
    end

  end
end