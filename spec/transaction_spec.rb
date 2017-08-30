require "spec_helper"

RSpec.describe Lightrail::Transaction do
  subject(:transaction) {Lightrail::Transaction}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_code) {'this-is-a-code'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_transaction_id) {'this-is-a-transaction-id'}

  let(:code_charge_params) {{
      value: -1,
      currency: 'USD',
      code: example_code,
  }}

  let(:card_id_charge_params) {{
      value: -1,
      currency: 'USD',
      card_id: example_card_id,
  }}

  let(:card_id_fund_params) {{
      value: 1,
      currency: 'USD',
      card_id: example_card_id,
  }}

  let(:card_id_pending_charge_params) {{
      value: -1,
      currency: 'USD',
      card_id: example_card_id,
      pending: true,
  }}

  let(:transaction_info) {{
      cardId: example_card_id,
      codeLastFour: 'TEST',
      currency: 'USD',
      transactionId: example_transaction_id,
      userSuppliedId: '123-abc-456-def',
      value: -1,
  }}


  describe ".charge_code" do
    context "when posting a drawdown transaction" do
      it "charges a code with minimum parameters" do
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{example_code}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
        transaction.charge_code(code_charge_params)
      end

      it "charges a code first if both code and cardId are present" do
        code_charge_params[:card_id] = example_card_id
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{example_code}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
        transaction.charge_code(code_charge_params)
      end
    end

    context "when posting a pending transaction" do
      it "posts a pending transaction to a code" do
        code_charge_params[:pending] = true
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{example_code}\/transactions/, hash_including(:value, :currency, :userSuppliedId, pending: true)).and_return({"transaction" => {}})
        transaction.charge_code(code_charge_params)
      end
    end

  end

  describe ".charge_card" do
    context "when posting a drawdown transaction" do
      it "charges a card with minimum parameters" do
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
        transaction.charge_card(card_id_charge_params)
      end
    end

    context "when posting a pending transaction" do
      it "posts a pending transaction to a card_id" do
        card_id_charge_params[:pending] = true
        expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency, :userSuppliedId, pending: true)).and_return({"transaction" => {}})
        transaction.charge_card(card_id_charge_params)
      end
    end

  end

  describe ".fund_card" do
    it "funds a card" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      transaction.fund_card(card_id_fund_params)
    end

    it "does not fund a code" do
      code_fund_params = {
          value: 1,
          currency: 'USD',
          code: example_code,
      }
      expect {transaction.fund_card(code_fund_params)}.to raise_error(Lightrail::LightrailArgumentError)
    end
  end

  describe ".void" do
    it "cancels a pending transaction" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions\/#{example_transaction_id}\/void/, Hash).and_return({"transaction" => {}})
      transaction.void(transaction_info)
    end
  end

  describe ".capture" do
    it "captures a pending transaction" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions\/#{example_transaction_id}\/capture/, Hash).and_return({"transaction" => {}})
      transaction.capture(transaction_info)
    end
  end

  describe ".refund" do
    it "refunds a drawdown transaction" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions\/#{example_transaction_id}\/refund/, Hash).and_return({"transaction" => {}})
      transaction.refund(transaction_info)
    end
  end
end