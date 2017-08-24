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

  let(:card_id_pending_charge_params) {{
      value: -1,
      currency: 'USD',
      card_id: ENV['LIGHTRAIL_TEST_CARD_ID'],
      pending: true,
  }}


  describe ".charge_code" do
    context "when posting a drawdown transaction" do
      it "charges a code with minimum parameters" do
        transac = transaction.charge_code(code_charge_params)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('DRAWDOWN')
      end

      it "charges a code first if both code and cardId are present"
    end

    context "when posting a pending transaction" do
      it "posts a pending transaction to a code" do
        code_charge_params[:pending] = true
        transac = transaction.charge_code(code_charge_params)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('PENDING_CREATE')
      end
    end

  end

  describe ".charge_card" do
    context "when posting a drawdown transaction" do
      it "charges a card with minimum parameters" do
        transac = transaction.charge_card(card_id_charge_params)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('DRAWDOWN')
      end
    end

    context "when posting a pending transaction" do
      it "posts a pending transaction to a card_id" do
        card_id_charge_params[:pending] = true
        transac = transaction.charge_card(card_id_charge_params)
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

  describe ".void" do
    it "cancels a pending transaction" do
      pending = transaction.charge_card(card_id_pending_charge_params)
      transac = transaction.void(pending)

      expect(transac).to have_key('transactionId')
      expect(transac['transactionType']).to eq('PENDING_VOID')
    end
  end

  describe ".capture" do
    it "captures a pending transaction" do
      pending = transaction.charge_card(card_id_pending_charge_params)
      transac = transaction.capture(pending)

      expect(transac).to have_key('transactionId')
      expect(transac['transactionType']).to eq('DRAWDOWN')
    end
  end

  describe ".refund" do
    it "refunds a drawdown transaction" do
      original_transac = transaction.charge_card(card_id_charge_params)
      transac = transaction.refund(original_transac)

      expect(transac).to have_key('transactionId')
      expect(transac['transactionType']).to eq('DRAWDOWN_REFUND')
    end
  end
end