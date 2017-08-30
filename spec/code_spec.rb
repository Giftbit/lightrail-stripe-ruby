require "spec_helper"

RSpec.describe Lightrail::Code do
  subject(:code) {Lightrail::Code}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_code) {'this-is-a-code'}

  let(:charge_params) {{
      value: 1,
      currency: 'USD',
      code: example_code,
  }}

  let(:balance_response) {{
      "principal" => {"currentValue" => 400, "state" => "ACTIVE", "programId" => "program-123456", "valueStoreId" => "value-123456"},
      "attached" => [{"currentValue" => 50, "state" => "ACTIVE", "programId" => "program-789", "valueStoreId" => "value-2468"},
                     {"currentValue" => 30, "state" => "EXPIRED", "programId" => "program-235", "valueStoreId" => "value-7643"}]
  }}

  describe ".charge" do
    it "posts a charge to a code" do
      expect(lightrail_connection).to receive(:make_post_request_and_parse_response).with(/codes\/#{example_code}\/transactions/, hash_including(:value, :currency, :userSuppliedId)).and_return({"transaction" => {}})
      code.charge(charge_params)
    end
  end

  describe ".get_balance_details" do
    it "gets the balance details by cardId" do
      expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/codes\/#{example_code}\/balance/).and_return({"balance" => {}})
      code.get_balance_details(example_code)
    end
  end

  describe ".get_total_balance" do
    it "gets the total balance for a code" do
      expect(code).to receive(:get_balance_details).with(example_code).and_return(balance_response)
      balance = code.get_total_balance(example_code)
      expect(balance).to be 450
    end
  end

end