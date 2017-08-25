require "spec_helper"

RSpec.describe Lightrail::Card do
  subject(:card) {Lightrail::Card}

  let(:charge_params) {{
      value: -1,
      currency: 'USD',
      card_id: ENV['LIGHTRAIL_TEST_CARD_ID'],
  }}

  let(:fund_params) {{
      value: 1,
      currency: 'USD',
      card_id: ENV['LIGHTRAIL_TEST_CARD_ID'],
  }}

  describe ".charge" do
    it "posts a charge to a card" do
      charge_response = card.charge(charge_params)
      expect(charge_response).to have_key('transactionId')
    end
  end

  describe ".fund" do
    it "funds a card" do
      fund_response = card.charge(charge_params)
      expect(fund_response).to have_key('transactionId')
    end
  end

  describe ".get_balance_details" do
    it "gets the balance details by cardId" do
      expect(card.get_balance_details(ENV['LIGHTRAIL_TEST_CARD_ID'])).to have_key('principal')
    end
  end

  describe ".get_total_balance" do
    it "gets the total balance for a card" do
      expect(card.get_total_balance(ENV['LIGHTRAIL_TEST_CARD_ID'])).to be_a(Integer)
    end
  end

end