require "spec_helper"

RSpec.describe Lightrail::StripeLightrailSplitTenderCharge do
  subject(:split_tender_charge) {Lightrail::StripeLightrailSplitTenderCharge}

  let(:lightrail_connection) {Lightrail::Connection}
  let(:lightrail_value) {Lightrail::LightrailValue}
  let(:lightrail_charge) {Lightrail::LightrailCharge}
  let(:stripe_charge) {Stripe::Charge}

  let(:example_code) {'this-is-a-code'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_contact_id) {'this-is-a-contact-id'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}
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
          transactionType: 'DRAWDOWN',
          userSuppliedId: '123-abc-456-def',
          value: -500,
      }
  )}

  let(:lightrail_simulated_transaction) {{
      "value" => -450,
      "cardId" => example_card_id,
      "currency" => "USD",
      "transactionBreakdown" => [{"value" => -450, "valueAvailableAfterTransaction" => 0, "valueStoreId" => "some-value-store"}]
  }}

  let(:stripe_charge_object) {
    charge = stripe_charge.new({:id => 'mock-stripe-charge'})
    charge.amount = 450
    charge
  }


  before do
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end

  describe ".create" do
    context "when given valid parameters" do
      it "charges the appropriate amounts to Stripe and Lightrail code" do
        expect(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -450})).and_return(lightrail_charge_instance)
        expect(stripe_charge).to receive(:create).with(hash_including({amount: 550})).and_return(stripe_charge_object)
        expect(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        split_tender_charge.create(charge_params, 450)
      end

      it "charges the appropriate amounts to Stripe and Lightrail cardId" do
        charge_params.delete(:code)
        charge_params[:card_id] = example_card_id

        expect(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -450})).and_return(lightrail_charge_instance)
        expect(stripe_charge).to receive(:create).with(hash_including({amount: 550})).and_return(stripe_charge_object)
        expect(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        split_tender_charge.create(charge_params, 450)
      end

      it "charges the appropriate amounts to Stripe and Lightrail contactId" do
        charge_params.delete(:code)
        charge_params[:contact_id] = example_contact_id

        allow(Lightrail::Account).to receive(:retrieve).with(hash_including(contact_id: example_contact_id, currency: 'USD')).and_return({'cardId' => example_card_id})

        expect(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -450})).and_return(lightrail_charge_instance)
        expect(stripe_charge).to receive(:create).with(hash_including({amount: 550})).and_return(stripe_charge_object)
        expect(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        split_tender_charge.create(charge_params, 450)
      end

      it "charges the appropriate amounts to Stripe and Lightrail shopperId" do
        charge_params.delete(:code)
        charge_params[:shopper_id] = example_shopper_id

        allow(Lightrail::Contact).to receive(:get_contact_id_from_id_or_shopper_id).with(hash_including({shopper_id: example_shopper_id})).and_return(example_contact_id)
        allow(Lightrail::Account).to receive(:retrieve).with({contact_id: example_contact_id, currency: 'USD'}).and_return({'cardId' => example_card_id})

        expect(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -450})).and_return(lightrail_charge_instance)
        expect(stripe_charge).to receive(:create).with(hash_including({amount: 550})).and_return(stripe_charge_object)
        expect(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        split_tender_charge.create(charge_params, 450)
      end

      it "adds the Stripe transaction ID to Lightrail metadata" do
        allow(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -450})).and_return(lightrail_charge_instance)
        allow(stripe_charge).to receive(:create).with(hash_including({amount: 550})).and_return(stripe_charge_object)

        expect(lightrail_charge_instance).to receive(:capture!).with(hash_including(:metadata => hash_including(:splitTenderChargeDetails))).and_return(lightrail_captured_transaction)

        split_tender_charge.create(charge_params, 450)
      end

      it "adjusts the LR share to respect Stripe's minimum charge amount when necessary" do
        charge_params[:amount] = 460
        stripe_charge_object.amount = 50

        allow(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        expect(lightrail_charge).to receive(:create).with(hash_including({pending: true, value: -410})).and_return(lightrail_charge_instance)
        expect(stripe_charge).to receive(:create).with(hash_including({amount: 50})).and_return(stripe_charge_object)

        split_tender_charge.create(charge_params, 410)
      end

      it "charges Lightrail only, when card balance is sufficient" do
        charge_params[:amount] = 1

        allow(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        expect(lightrail_charge).to receive(:create).with(hash_including({value: -1})).and_return(lightrail_charge_instance)
        expect(stripe_charge).not_to receive(:create)

        split_tender_charge.create(charge_params, 1)
      end

      it "charges Lightrail only, when no Stripe params given and Lightrail card value is sufficient" do
        charge_params[:amount] = 1
        charge_params.delete(:source)

        allow(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        expect(lightrail_charge).to receive(:create).with(hash_including({value: -1})).and_return(lightrail_charge_instance)
        expect(stripe_charge).not_to receive(:create)

        split_tender_charge.create(charge_params, 1)
      end

      it "charges Stripe only, when Lightrail amount set to 0" do
        charge_params.delete(:code)

        expect(lightrail_value).not_to receive(:retrieve_code_details || :retrieve_card_details)
        expect(lightrail_charge).not_to receive(:create)
        expect(stripe_charge).to receive(:create).and_return(stripe_charge_object)

        split_tender_charge.create(charge_params, 0)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when missing both Stripe and Lightrail payment options" do
        charge_params.delete(:code)
        charge_params.delete(:source)
        expect {split_tender_charge.create(charge_params, 0)}.to raise_error(Lightrail::LightrailArgumentError)
      end
    end
  end

  describe ".create_with_automatic_split" do
    context "when given valid params" do
      it "passes the Stripe and Lightrail amounts to .create" do
        expect(Lightrail::Code).to receive(:simulate_charge).with(hash_including(charge_params)).and_return(lightrail_simulated_transaction)

        expect(lightrail_charge).to receive(:create).with(hash_including({value: -450})).and_return(lightrail_charge_instance)
        expect(stripe_charge).to receive(:create).with(hash_including({amount: 550})).and_return(stripe_charge_object)
        expect(lightrail_charge_instance).to receive(:capture!).and_return(lightrail_captured_transaction)

        split_tender_charge.create_with_automatic_split(charge_params)
      end
    end
  end
end
