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
    end
  end

  describe ".fund" do
    it "funds a card" do
      transac = transaction.fund(card_id_fund_params)
      expect(transac).to have_key('transactionId')
      expect(transac['transactionType']).to eq('FUND')
    end

    it "does not fund a code" do
      code_fund_params = {
          value: 1,
          currency: 'USD',
          code: ENV['LIGHTRAIL_TEST_CODE'],
      }
      expect {transaction.fund(code_fund_params)}.to raise_error(Lightrail::LightrailArgumentError)
    end
  end

end