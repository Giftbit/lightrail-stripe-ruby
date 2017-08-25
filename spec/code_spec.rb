require "spec_helper"

RSpec.describe Lightrail::Code do
  subject(:code) {Lightrail::Code}

  let(:charge_params) {{
      value: -1,
      currency: 'USD',
      code: ENV['LIGHTRAIL_TEST_CODE'],
  }}

  describe ".charge" do
    it "posts a charge to a code" do
      charge_response = code.charge(charge_params)
      expect(charge_response).to have_key('transactionId')
    end
  end

  describe ".get_balance_details" do
    it "gets the balance details by cardId" do
      expect(code.get_balance_details(ENV['LIGHTRAIL_TEST_CODE'])).to have_key('principal')
    end
  end

  describe ".get_total_balance" do
    it "gets the total balance for a code" do
      expect(code.get_total_balance(ENV['LIGHTRAIL_TEST_CODE'])).to be_a(Integer)
    end
  end

end