require "spec_helper"

RSpec.describe LightrailClientRuby::GiftCharge do
  subject(:gift_charge) {LightrailClientRuby::GiftCharge}

  describe ".create" do
    context "when given valid params" do
      it "creates a drawdown transaction with minimum required params" do
        charge_object = {
            amount: 1,
            currency: 'USD',
            code: ENV['TEST_CODE'],
        }
        charge_response = gift_charge.create(charge_object)
        expect(charge_response['transaction']['transactionType']).to eq('DRAWDOWN')
      end

      it "uses userSuppliedId if supplied in param hash" do
        charge_object = {
            amount: 1,
            currency: 'USD',
            code: ENV['TEST_CODE'],
            userSuppliedId: 'test-charge-' + rand().to_s,
        }
        charge_response = gift_charge.create(charge_object)
        expect(charge_response['transaction']['userSuppliedId']).to eq(charge_object[:userSuppliedId])
      end

      it "creates a pending transaction when 'capture=false'" do
        charge_object = {
            amount: 1,
            currency: 'USD',
            code: ENV['TEST_CODE'],
            capture: false,
        }
        charge_response = gift_charge.create(charge_object)
        expect(charge_response['transaction']['transactionType']).to eq('PENDING_CREATE')
      end

      context "when an error response comes back from the API anyway" do
        it "should produce a meaningful error" do
          charge_object = {
              amount: 1,
              currency: 'USD',
              code: ENV['TEST_CODE'],
              metadata: {
                  giftbit_exception_action: 'transaction:create'
              }
          }
          expect{gift_charge.create(charge_object)}.to raise_error(LightrailClientRuby::LightrailError, /Server responded with/), "expected a LightrailError with message 'Server responded with:'"
        end
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {gift_charge.create()}.to raise_error(ArgumentError), "called GiftCharge.create with no params"
        expect {gift_charge.create({})}.to raise_error(ArgumentError), "called GiftCharge.create with empty object"
        expect {gift_charge.create({code: ENV['TEST_CODE']})}.to raise_error(ArgumentError), "called GiftCharge.create with '{code: ENV['TEST_CODE']}'"
        expect {gift_charge.create([])}.to raise_error(ArgumentError), "called GiftCharge.create with empty array"
      end
    end

  end

  describe ".cancel" do
    before(:each) do
      charge_object_to_handle = {
          amount: 1,
          currency: 'USD',
          code: ENV['TEST_CODE'],
          capture: false,
      }
      @pending_to_void = gift_charge.create(charge_object_to_handle)
    end

    context "when given valid params" do
      it "voids a pending transaction" do
        voiding_response = gift_charge.cancel(@pending_to_void)
        expect(voiding_response['transaction']['transactionType']).to eq('PENDING_VOID')
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing or in the wrong format" do
        @pending_to_void['transaction'].delete('transactionId')
        expect {gift_charge.cancel(@pending_to_void)}.to raise_error(ArgumentError), "called GiftCharge.cancel with no params"
        expect {gift_charge.cancel({})}.to raise_error(ArgumentError), "called GiftCharge.cancel with empty object"
        expect {gift_charge.cancel([])}.to raise_error(ArgumentError), "called GiftCharge.cancel with empty array"
        expect {gift_charge.cancel('')}.to raise_error(ArgumentError), "called GiftCharge.cancel with empty string"
      end
    end
  end

  describe ".capture" do
    before(:each) do
      charge_object_to_handle = {
          amount: 1,
          currency: 'USD',
          code: ENV['TEST_CODE'],
          capture: false,
      }
      @pending_to_capture = gift_charge.create(charge_object_to_handle)
    end

    context "when given valid params" do
      it "captures a pending transaction" do
        capture_response = gift_charge.capture(@pending_to_capture)
        expect(capture_response['transaction']['transactionType']).to eq('DRAWDOWN')
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing or in the wrong format" do
        @pending_to_capture['transaction'].delete('transactionId')
        expect {gift_charge.capture(@pending_to_void)}.to raise_error(ArgumentError), "called GiftCharge.capture with no params"
        expect {gift_charge.capture({})}.to raise_error(ArgumentError), "called GiftCharge.capture with empty object"
        expect {gift_charge.capture([])}.to raise_error(ArgumentError), "called GiftCharge.capture with empty array"
        expect {gift_charge.capture('')}.to raise_error(ArgumentError), "called GiftCharge.capture with empty string"
      end
    end
  end



end