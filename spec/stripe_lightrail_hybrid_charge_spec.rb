require "spec_helper"

RSpec.describe LightrailClient::StripeLightrailHybridCharge do
  subject(:hybrid_charge) {LightrailClient::StripeLightrailHybridCharge}

  before do
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end

  context "EXAMPLE" do
    it "posts a charge to the Stripe API" do
      charge_params = {
          amount: 55,
          currency: 'USD',
          source: 'tok_mastercard',
      }

      charge_response = Stripe::Charge.create(charge_params)
      expect(charge_response).to be_a(Stripe::Charge)
    end
  end

  describe ".create" do
    context "when given valid params" do
      it "charges the appropriate amounts to Stripe and Lightrail with minimum required params" do
        # TODO: set up test card to have only enough balance for partial payment (then either revert or let spec helper restore afterwards)

        # TODO: improve translator (https://trello.com/c/7v69y2YS/38-improve-translator)
        charge_params = {
            amount: 1000,
            currency: 'USD',
            lightrail_code: ENV['TEST_CODE_497'],
            code: ENV['TEST_CODE_497'],
            stripe_source: 'tok_mastercard',
        }

        hybrid_charge_response = hybrid_charge.create(charge_params)

        LightrailClient::Refund.create(hybrid_charge_response.lightrail_charge)

        expect(hybrid_charge_response).to be_a(hybrid_charge)
      end

      it "charges Lightrail only, when card balance is sufficient" do
        charge_params = {
            amount: 1,
            currency: 'USD',
            lightrail_code: ENV['TEST_CODE'],
            code: ENV['TEST_CODE'],
            stripe_source: 'tok_mastercard',
        }
        hybrid_charge_response = hybrid_charge.create(charge_params)
        # puts "#{hybrid_charge_response.inspect}"
        expect(hybrid_charge_response).to be_a(hybrid_charge)
        expect(hybrid_charge_response.lightrail_charge).to be_a(LightrailClient::LightrailCharge)
        expect(hybrid_charge_response.stripe_charge).to be(nil)
      end

      it "charges Lightrail only, when no Stripe params given" do
        charge_params = {
            amount: 1,
            currency: 'USD',
            lightrail_code: ENV['TEST_CODE'],
            code: ENV['TEST_CODE'],
        }
        hybrid_charge_response = hybrid_charge.create(charge_params)
        expect(hybrid_charge_response).to be_a(hybrid_charge)
        expect(hybrid_charge_response.lightrail_charge).to be_a(LightrailClient::LightrailCharge)
        expect(hybrid_charge_response.stripe_charge).to be(nil)
      end

      it "charges Stripe only, when no Lightrail params given" do
        charge_params = {
            amount: 1000,
            currency: 'USD',
            stripe_source: 'tok_mastercard',
        }
        hybrid_charge_response = hybrid_charge.create(charge_params)
        expect(hybrid_charge_response).to be_a(hybrid_charge)
        expect(hybrid_charge_response.stripe_charge).to be_a(Stripe::Charge)
        expect(hybrid_charge_response.lightrail_charge).to be(nil)
      end

    end
  end

end