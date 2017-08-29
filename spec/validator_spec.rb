require "spec_helper"

RSpec.describe Lightrail::Validator do
  subject(:validator) {Lightrail::Validator}

  let(:code_charge_params) {{
      amount: 1,
      currency: 'USD',
      code: ENV['LIGHTRAIL_TEST_CODE'],
  }}

  let(:card_id_charge_params) {{
      amount: 1,
      currency: 'USD',
      cardId: ENV['LIGHTRAIL_TEST_CARD_ID'],
  }}

  let(:card_id_fund_params) {{
      cardId: ENV['LIGHTRAIL_TEST_CARD_ID'],
      amount: 20,
      currency: 'USD',
  }}

  describe "grouped validator methods" do
    let(:lr_argument_error) {Lightrail::LightrailArgumentError}

    describe ".validate_charge_object!" do
      it "returns true when the required keys are present" do
        expect(validator.validate_charge_object!(code_charge_params)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        code_charge_params.delete(:code)
        expect {validator.validate_charge_object!(code_charge_params)}.to raise_error(lr_argument_error, /charge_params/)
        expect {validator.validate_charge_object!({})}.to raise_error(lr_argument_error, /charge_params/)
      end
    end

    describe ".validate_transaction_response!" do
      it "returns true when the required keys are present & formatted" do
        transaction_response = Lightrail::LightrailCharge.create(code_charge_params)
        expect(validator.validate_transaction_response!(transaction_response)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        transaction_response = {
            'transaction' => {
                'transactionId' => ENV['LIGHTRAIL_TEST_TRANSACTION_ID'],
            }
        }
        expect {validator.validate_transaction_response!(transaction_response)}.to raise_error(lr_argument_error, /transaction_response/)
        expect {validator.validate_transaction_response!({})}.to raise_error(lr_argument_error, /transaction_response/)
        expect {validator.validate_transaction_response!([])}.to raise_error(lr_argument_error, /transaction_response/)
      end
    end

    describe ".validate_fund_object!" do
      it "returns true when the required keys are present & formatted" do
        expect(validator.validate_fund_object!(card_id_fund_params)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        fund_params = {amount: 1, currency: 'USD'}
        expect {validator.validate_fund_object!(fund_params)}.to raise_error(lr_argument_error, /fund_params/)
        expect {validator.validate_fund_object!({})}.to raise_error(lr_argument_error, /fund_params/)
        expect {validator.validate_fund_object!([])}.to raise_error(lr_argument_error, /fund_params/)
      end
    end

    describe ".validate_ping_response!" do
      it "returns true when the required keys are present & formatted" do
        ping_response = {
            'user' => {
                'username' => 'test@test.com',
            }
        }
        expect(validator.validate_ping_response!(ping_response)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        ping_response = {
            'user' => {
                'username' => '',
            }
        }
        expect {validator.validate_ping_response!(ping_response)}.to raise_error(lr_argument_error, /ping_response/)
        expect {validator.validate_ping_response!({})}.to raise_error(lr_argument_error, /ping_response/)
        expect {validator.validate_ping_response!([])}.to raise_error(lr_argument_error, /ping_response/)
      end
    end

  end

  describe "single validator methods" do
    let(:lr_argument_error) {Lightrail::LightrailArgumentError}

    describe ".validate_card_id!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_card_id! (ENV['LIGHTRAIL_TEST_CARD_ID'])).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_card_id! ('')}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.validate_card_id! ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_card_id! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_card_id! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_card_id! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_code!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_code! (ENV['LIGHTRAIL_TEST_CODE'])).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_code! ('')}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.validate_code! ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_code! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_code! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_code! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_transaction_id!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_transaction_id! (ENV['LIGHTRAIL_TEST_TRANSACTION_ID'])).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_transaction_id! ('')}.to raise_error(lr_argument_error), "called with empty string"
        # expect{validator.is_transaction_id_valid? ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_transaction_id! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_transaction_id! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_transaction_id! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_amount!" do
      it "returns true for an integer" do
        expect(validator.validate_amount! (5)).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_amount! (5.5)}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.validate_amount! ('five')}.to raise_error(lr_argument_error), "called with number as string"
        expect {validator.validate_amount! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_amount! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_currency!" do
      it "returns true for an string of the right format" do
        expect(validator.validate_currency! ('USD')).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_currency! ('XXXX')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_currency! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_currency! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_currency! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".validate_username!" do
      it "returns true for a string of the right format" do
        expect(validator.validate_username! ('test@test.com')).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.validate_username! ('')}.to raise_error(lr_argument_error), "called with empty string"
        # expect{validator.is_transaction_id_valid? ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.validate_username! (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.validate_username! ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.validate_username! ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

  end

end
