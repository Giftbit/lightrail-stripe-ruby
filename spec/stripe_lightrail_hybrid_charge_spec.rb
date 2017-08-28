require "spec_helper"

RSpec.describe Lightrail::StripeLightrailHybridCharge do
  subject(:hybrid_charge) {Lightrail::StripeLightrailHybridCharge}

  let(:lightrail_connection) {Lightrail::Connection}
  let(:lightrail_value) {Lightrail::LightrailValue}
  let(:lightrail_charge) {Lightrail::LightrailCharge}
  let(:stripe_charge) {Stripe::Charge}

  let(:example_code) {'this-is-a-code'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_pending_transaction_id) {'transaction-pending-123456'}
  let(:example_captured_transaction_id) {'transaction-captured-123456'}

  let(:charge_params) {{
      amount: 1000,
      currency: 'USD',
      code: example_code,
      source: 'tok_mastercard',
  }}

  let (:lightrail_charge_instance) {instance_double(lightrail_charge)}

  let(:lightrail_captured_transaction) {lightrail_charge.new(
      {
          cardId: example_card_id,
          codeLastFour: 'TEST',
          currency: 'USD',
          transactionId: example_captured_transaction_id,
          transactionType: 'DRADOWN',
          userSuppliedId: '123-abc-456-def',
          value: -500,
      }
  )}

  let(:lightrail_value_object) {lightrail_value.new(
      {principal: {"currentValue" => 400, "state" => "ACTIVE", "programId" => "program-123456", "valueStoreId" => "value-123456"},
       attached: [{"currentValue" => 50, "state" => "ACTIVE", "programId" => "program-789", "valueStoreId" => "value-2468"}]}
  )}

  let(:stripe_charge_object) {
    charge = stripe_charge.new({:id => 'mock-stripe-charge'})
    charge.amount = 450
    charge
  }


  before do
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end

  describe ".create" do
    context "when given valid params" do
      it "charges the appropriate amounts to Stripe and Lightrail with minimum required params" do
        allow(lightrail_value).to receive(:retrieve_by_code).with(example_code).and_return(lightrail_value_object)

        expect(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -450})).and_return(lightrail_charge_instance)
        expect(stripe_charge).to receive(:create).with(hash_including({amount: 550})).and_return(stripe_charge_object)
        expect(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        hybrid_charge.create(charge_params)
      end

      it "adds the Stripe transaction ID to Lightrail metadata" do
        allow(lightrail_value).to receive(:retrieve_by_code).with(example_code).and_return(lightrail_value_object)
        allow(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -450})).and_return(lightrail_charge_instance)
        allow(stripe_charge).to receive(:create).with(hash_including({amount: 550})).and_return(stripe_charge_object)

        expect(lightrail_charge_instance).to receive(:capture!).with(hash_including(:metadata => hash_including(:hybridChargeDetails))).and_return(lightrail_captured_transaction)

        hybrid_charge.create(charge_params)
      end

      it "adjusts the LR share to respect Stripe's minimum charge amount when necessary" do
        charge_params[:amount] = 460
        stripe_charge_object.amount = 50

        allow(lightrail_value).to receive(:retrieve_by_code).with(example_code).and_return(lightrail_value_object)
        allow(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        expect(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -410})).and_return(lightrail_charge_instance)
        expect(stripe_charge).to receive(:create).with(hash_including({amount: 50})).and_return(stripe_charge_object)

        hybrid_charge.create(charge_params)
      end

      it "charges Lightrail only, when card balance is sufficient" do
        charge_params[:amount] = 1

        allow(lightrail_value).to receive(:retrieve_by_code).with(example_code).and_return(lightrail_value_object)
        allow(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        expect(lightrail_charge).to receive(:create).with(hash_including({value: -1})).and_return(lightrail_charge_instance)
        expect(stripe_charge).not_to receive(:create)

        hybrid_charge.create(charge_params)
      end

      it "charges Lightrail only, when no Stripe params given" do
        charge_params[:amount] = 1
        charge_params.delete(:source)

        allow(lightrail_value).to receive(:retrieve_by_code).with(example_code).and_return(lightrail_value_object)
        allow(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        expect(lightrail_charge).to receive(:create).with(hash_including({value: -1})).and_return(lightrail_charge_instance)
        expect(stripe_charge).not_to receive(:create)

        hybrid_charge.create(charge_params)
      end

      it "charges Stripe only, when no Lightrail params given" do
        charge_params.delete(:code)

        expect(lightrail_value).not_to receive(:retrieve_by_code || :retrieve_by_card_id)
        expect(lightrail_charge).not_to receive(:create)
        expect(stripe_charge).to receive(:create).and_return(stripe_charge_object)


        hybrid_charge.create(charge_params)
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
