require "spec_helper"

RSpec.describe Lightrail::Card do
  subject(:card) {Lightrail::Card}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_card_id) {'this-is-a-card-id'}

  let(:charge_params) {{
      value: -1,
      currency: 'USD',
      card_id: example_card_id,
  }}

  let(:fund_params) {{
      value: 1,
      currency: 'USD',
      card_id: example_card_id,
  }}

  let(:balance_response) {{
      "principal" => {"currentValue" => 400, "state" => "ACTIVE", "programId" => "program-123456", "valueStoreId" => "value-123456"},
      "attached" => [{"currentValue" => 50, "state" => "ACTIVE", "programId" => "program-789", "valueStoreId" => "value-2468"},
                     {"currentValue" => 30, "state" => "EXPIRED", "programId" => "program-235", "valueStoreId" => "value-7643"}]
  }}

  describe ".charge" do
    it "posts a charge to a card" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      card.charge(charge_params)
    end
  end

  describe ".fund" do
    it "funds a card" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/cards\/#{example_card_id}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      card.fund(fund_params)
    end
  end

  describe ".get_balance_details" do
    it "gets the balance details by cardId" do
      expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/cards\/#{example_card_id}\/balance/).and_return({"balance" => {}})
      card.get_balance_details(example_card_id)
    end
  end

  describe ".get_total_balance" do
    it "gets the total balance for a card" do
      expect(card).to receive(:get_balance_details).with(example_card_id).and_return(balance_response)
      balance = card.get_total_balance(example_card_id)
      expect(balance).to be 450
    end
  end

end