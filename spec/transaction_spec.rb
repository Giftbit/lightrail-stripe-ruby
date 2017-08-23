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

  describe ".create" do
    context "when posting a drawdown transaction" do
      it "charges a code with minimum parameters" do
        transac = transaction.create(code_charge_params, :code_drawdown)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('DRAWDOWN')
      end

      it "charges a card with minimum parameters" do
        transac = transaction.create(card_id_charge_params, :card_id_drawdown)
        expect(transac).to have_key('transactionId')
        expect(transac['transactionType']).to eq('DRAWDOWN')
      end
    end

  end
end