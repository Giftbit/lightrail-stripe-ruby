require "spec_helper"

RSpec.describe LightrailClientRuby::GiftCharge do

  describe ".create" do
    context "when given valid params" do
      it "creates a drawdown transaction with minimum required params" do
        charge_object = {
            amount: 1,
            currency: 'USD',
          code: ENV['TEST_CODE'],
        }
        charge_response = LightrailClientRuby::GiftCharge.create(charge_object)
        expect(charge_response['transaction']['transactionType']).to eq('DRAWDOWN')
      end

      it "uses userSuppliedId if supplied in param hash" do
        charge_object = {
            amount: 1,
            currency: 'USD',
            code: ENV['TEST_CODE'],
            userSuppliedId: 'test-charge-' + rand().to_s,
        }
        charge_response = LightrailClientRuby::GiftCharge.create(charge_object)
        expect(charge_response['transaction']['userSuppliedId']).to eq(charge_object[:userSuppliedId])
      end

      it "creates a pending transaction when 'capture=false'" do
        charge_object = {
            amount: 1,
            currency: 'USD',
            code: ENV['TEST_CODE'],
            capture: false,
        }
        charge_response = LightrailClientRuby::GiftCharge.create(charge_object)
        expect(charge_response['transaction']['transactionType']).to eq('PENDING_CREATE')
      end
    end

  end

  describe ".cancel" do
    it "voids a pending transaction" do
      charge_object_to_handle = {
          amount: 1,
          currency: 'USD',
          code: ENV['TEST_CODE'],
          capture: false,
      }
      pending_to_void = LightrailClientRuby::GiftCharge.create(charge_object_to_handle)
      voiding_response = LightrailClientRuby::GiftCharge.cancel(pending_to_void)
      expect(voiding_response['transaction']['transactionType']).to eq('PENDING_VOID')
    end
  end

  describe ".capture" do
    it "captures a pending transaction" do
      charge_object_to_handle = {
          amount: 1,
          currency: 'USD',
          code: ENV['TEST_CODE'],
          capture: false,
      }
      pending_to_capture = LightrailClientRuby::GiftCharge.create(charge_object_to_handle)
      capture_response = LightrailClientRuby::GiftCharge.capture(pending_to_capture)
      expect(capture_response['transaction']['transactionType']).to eq('DRAWDOWN')
    end
  end

end