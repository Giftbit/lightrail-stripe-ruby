require "spec_helper"

RSpec.describe Lightrail::Transaction do
  subject(:transaction) {Lightrail::Transaction}

  let(:code_charge_params) {{
      value: -1,
      currency: 'USD',
      code: ENV['LIGHTRAIL_TEST_CODE'],
  }}

  let(:card_id_charge_params) {{
      value: -1,
      currency: 'USD',
      card_id: ENV['LIGHTRAIL_TEST_CARD_ID'],
  }}

  let(:card_id_fund_params) {{
      value: 1,
      currency: 'USD',
      card_id: ENV['LIGHTRAIL_TEST_CARD_ID'],
  }}


  describe ".charge" do
    context "when posting a drawdown transaction" do
      it "charges a code with minimum parameters" do
        transac = transaction.charge(code_charge_params, :code_drawdown)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('DRAWDOWN')
      end

      it "charges a card with minimum parameters" do
        transac = transaction.charge(card_id_charge_params, :card_id_drawdown)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('DRAWDOWN')
      end

      it "charges a code first if both code and cardId are present"
    end

    context "when posting a pending transaction" do
      it "posts a pending transaction to a code" do
        transac = transaction.charge(code_charge_params, :code_pending)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('PENDING_CREATE')
      end

      it "posts a pending transaction to a card_id" do
        transac = transaction.charge(card_id_charge_params, :card_id_pending)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('PENDING_CREATE')
      end
    end
  end

  describe ".fund_card" do
    it "funds a card" do
      transac = transaction.fund_card(card_id_fund_params)
      expect(transac).to have_key('transactionId')
      expect(transac['transactionType']).to eq('FUND')
    end

    it "does not fund a code" do
      code_fund_params = {
          value: 1,
          currency: 'USD',
          code: ENV['LIGHTRAIL_TEST_CODE'],
      }
      expect {transaction.fund_card(code_fund_params)}.to raise_error(Lightrail::LightrailArgumentError)
    end
  end

  describe ".cancel" do
    it "cancels a pending transaction"
  end

  describe ".capture" do
    it "captures a pending transaction"
  end

  describe ".refund" do
    it "refunds a drawdown transaction"
  end
end