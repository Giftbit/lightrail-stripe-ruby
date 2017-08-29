require "spec_helper"

RSpec.describe Lightrail::StripeLightrailHybridCharge do
  subject(:hybrid_charge) {Lightrail::StripeLightrailHybridCharge}

  let(:charge_params) {{
      amount: 1000,
      currency: 'USD',
      code: ENV['LIGHTRAIL_TEST_CODE'],
      source: 'tok_mastercard',
  }}


  before do
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end

  describe ".create" do
    context "when given valid params" do
      it "charges the appropriate amounts to Stripe and Lightrail with minimum required params" do
        # TODO: improve translator (https://trello.com/c/7v69y2YS/38-improve-translator)
        hybrid_charge_response = hybrid_charge.create(charge_params)
        Lightrail::Refund.create(hybrid_charge_response.lightrail_charge)
        expect(hybrid_charge_response).to be_a(hybrid_charge)
      end

      it "adds the Stripe transaction ID to Lightrail metadata" do
        hybrid_charge_response = hybrid_charge.create(charge_params)
        Lightrail::Refund.create(hybrid_charge_response.lightrail_charge)
        expect(hybrid_charge_response.lightrail_charge.metadata['hybridChargeDetails']['stripeTransactionId']).to eq(hybrid_charge_response.stripe_charge.id)
      end

      it "adjusts the LR share to respect Stripe's minimum charge amount when necessary" do
        charge_params[:amount] = 510
        hybrid_charge_response = hybrid_charge.create(charge_params)
        Lightrail::Refund.create(hybrid_charge_response.lightrail_charge)
        expect(hybrid_charge_response.lightrail_charge.value).to eq(-460)
      end

      it "charges Lightrail only, when card balance is sufficient" do
        charge_params[:amount] = 1
        hybrid_charge_response = hybrid_charge.create(charge_params)
        expect(hybrid_charge_response).to be_a(hybrid_charge)
        expect(hybrid_charge_response.lightrail_charge).to be_a(Lightrail::LightrailCharge)
        expect(hybrid_charge_response.stripe_charge).to be(nil)
      end

      it "charges Lightrail only, when no Stripe params given" do
        charge_params[:amount] = 1
        charge_params.delete(:source)
        hybrid_charge_response = hybrid_charge.create(charge_params)
        expect(hybrid_charge_response).to be_a(hybrid_charge)
        expect(hybrid_charge_response.lightrail_charge).to be_a(Lightrail::LightrailCharge)
        expect(hybrid_charge_response.stripe_charge).to be(nil)
      end

      it "charges Stripe only, when no Lightrail params given" do
        charge_params.delete(:code)
        hybrid_charge_response = hybrid_charge.create(charge_params)
        expect(hybrid_charge_response).to be_a(hybrid_charge)
        expect(hybrid_charge_response.stripe_charge).to be_a(Stripe::Charge)
        expect(hybrid_charge_response.lightrail_charge).to be(nil)
      end

    end

    context "when given bad/missing params" do
      it "throws an error when missing both Stripe and Lightrail payment options" do
        charge_params.delete(:code)
        charge_params.delete(:source)
        expect {hybrid_charge.create(charge_params)}.to raise_error(Lightrail::LightrailArgumentError)
      end
    end

  end

end
