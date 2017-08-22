require "spec_helper"

RSpec.describe Lightrail::LightrailCharge do
  subject(:lightrail_charge) {Lightrail::LightrailCharge}

  describe ".new" do
    it "creates a new charge object from valid API response" do
      charge_params = {
          amount: 1,
          currency: 'USD',
          code: ENV['LIGHTRAIL_TEST_CODE'],
      }
      charge_response = lightrail_charge.create(charge_params)
      expect(charge_response).to be_a(lightrail_charge)
    end
  end

  describe ".create" do
    context "when given valid params" do
      it "creates a drawdown code transaction with minimum required params" do
        charge_params = {
            amount: 1,
            currency: 'USD',
            code: ENV['LIGHTRAIL_TEST_CODE'],
        }
        charge_response = lightrail_charge.create(charge_params)
        expect(charge_response).to be_a(lightrail_charge)
        expect(charge_response.transactionType).to eq('DRAWDOWN')
      end

      it "creates a drawdown card transaction with minimum required params" do
        charge_params = {
            amount: 1,
            currency: 'USD',
            cardId: ENV['LIGHTRAIL_TEST_CARD_ID'],
        }
        charge_response = lightrail_charge.create(charge_params)
        expect(charge_response).to be_a(lightrail_charge)
        expect(charge_response.transactionType).to eq('DRAWDOWN')
      end

      it "uses userSuppliedId if supplied in param hash" do
        charge_params = {
            amount: 1,
            currency: 'USD',
            code: ENV['LIGHTRAIL_TEST_CODE'],
            userSuppliedId: 'test-charge-' + rand().to_s,
        }
        charge_response = lightrail_charge.create(charge_params)
        expect(charge_response.userSuppliedId).to eq(charge_params[:userSuppliedId])
      end

      it "uses 'value' instead of 'amount' if supplied in param hash" do
        charge_params = {
            amount: 1,
            value: -2,
            currency: 'USD',
            code: ENV['LIGHTRAIL_TEST_CODE'],
            userSuppliedId: 'test-charge-' + rand().to_s,
        }
        charge_response = lightrail_charge.create(charge_params)
        expect(charge_response.value).to eq(charge_params[:value])
      end

      it "creates a pending transaction when 'capture=false'" do
        charge_params = {
            amount: 1,
            currency: 'USD',
            code: ENV['LIGHTRAIL_TEST_CODE'],
            capture: false,
        }
        charge_response = lightrail_charge.create(charge_params)
        expect(charge_response.transactionType).to eq('PENDING_CREATE')
      end

      it "creates a pending transaction when 'pending=true'" do
        charge_params = {
            amount: 1,
            currency: 'USD',
            code: ENV['LIGHTRAIL_TEST_CODE'],
            pending: true,
        }
        charge_response = lightrail_charge.create(charge_params)
        expect(charge_response.transactionType).to eq('PENDING_CREATE')
      end

      context "when an error response comes back from the API anyway" do
        it "should produce a meaningful error" do
          charge_params = {
              amount: 1,
              currency: 'USD',
              code: ENV['LIGHTRAIL_TEST_CODE'],
              metadata: {
                  giftbit_exception_action: 'transaction:create'
              }
          }
          expect {lightrail_charge.create(charge_params)}.to raise_error(Lightrail::LightrailError, /Server responded with/), "expected a LightrailError with message 'Server responded with:'"
        end
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_charge.create()}.to raise_error(ArgumentError), "called LightrailCharge.create with no params"
        expect {lightrail_charge.create({})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailCharge.create with empty object"
        expect {lightrail_charge.create({code: ENV['LIGHTRAIL_TEST_CODE']})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailCharge.create with '{code: ENV['LIGHTRAIL_TEST_CODE']}'"
        expect {lightrail_charge.create([])}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailCharge.create with empty array"
      end
    end

  end

  describe "#cancel" do
    before(:each) do
      charge_params_to_handle = {
          amount: 1,
          currency: 'USD',
          code: ENV['LIGHTRAIL_TEST_CODE'],
          capture: false,
      }
      @pending_to_void = lightrail_charge.create(charge_params_to_handle)
    end

    context "called on a valid pending transaction" do
      it "voids a pending transaction" do
        voiding_response = @pending_to_void.cancel!
        expect(voiding_response.transactionType).to eq('PENDING_VOID')
      end
    end

    context "when called on an invalid pending transaction" do
      it "throws an error when required vars are missing or in the wrong format" do
        @pending_to_void.remove_instance_variable(:@transactionId)
        expect {@pending_to_void.cancel!}.to raise_error(Lightrail::LightrailArgumentError)
      end

      it "throw an error when the transaction has already been captured (not voided)" do
        @pending_to_void.capture!
        expect {@pending_to_void.cancel!}.to raise_error(Lightrail::LightrailError)
      end
    end
  end

  describe "#capture" do
    before(:each) do
      charge_params_to_handle = {
          amount: 1,
          currency: 'USD',
          code: ENV['LIGHTRAIL_TEST_CODE'],
          capture: false,
      }
      @pending_to_capture = lightrail_charge.create(charge_params_to_handle)
    end

    context "called on a valid pending transaction" do
      it "captures a pending transaction" do
        capture_response = @pending_to_capture.capture!
        expect(capture_response.transactionType).to eq('DRAWDOWN')
      end
    end

    context "when called on an invalid pending transaction" do
      it "throws an error when required vars are missing or in the wrong format" do
        @pending_to_capture.remove_instance_variable(:@transactionId)
        expect {@pending_to_capture.capture!}.to raise_error(Lightrail::LightrailArgumentError)
      end

      it "throw an error when the transaction has already been voided (not captured)" do
        @pending_to_capture.cancel!
        expect {@pending_to_capture.capture!}.to raise_error(Lightrail::LightrailError)
      end
    end
  end


end