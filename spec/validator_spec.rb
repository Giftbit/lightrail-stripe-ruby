require "spec_helper"

RSpec.describe LightrailClientRuby::Validator do
  subject(:validator) {LightrailClientRuby::Validator}

  describe "grouped validator methods" do
    let(:lr_argument_error) {LightrailClientRuby::LightrailArgumentError}

    describe ".is_valid_charge_object?" do
      it "returns true when the required keys are present" do
        charge_object = {
            amount: 1,
            currency: 'USD',
            code: ENV['TEST_CODE'],
        }
        expect(validator.is_valid_charge_object?(charge_object)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        charge_object = {
            amount: 1,
            currency: 'USD',
        }
        expect{validator.is_valid_charge_object?(charge_object)}.to raise_error(lr_argument_error, /charge_object/)
        expect{validator.is_valid_charge_object?({})}.to raise_error(lr_argument_error, /charge_object/)
      end
    end

    describe ".is_valid_transaction_response?" do
      it "returns true when the required keys are present & formatted" do
        transaction_response = {
            'transaction' => {
                'transactionId' => ENV['TEST_TRANSACTION_ID'],
                'cardId' => ENV['TEST_CARD_ID']
            }
        }
        expect(validator.is_valid_transaction_response?(transaction_response)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        transaction_response = {
            'transaction' => {
                'transactionId' => ENV['TEST_TRANSACTION_ID'],
            }
        }
        expect{validator.is_valid_transaction_response?(transaction_response)}.to raise_error(lr_argument_error, /transaction_response/)
        expect{validator.is_valid_transaction_response?({})}.to raise_error(lr_argument_error, /transaction_response/)
        expect{validator.is_valid_transaction_response?([])}.to raise_error(lr_argument_error, /transaction_response/)
      end
    end

    describe ".is_valid_fund_object?" do
      it "returns true when the required keys are present & formatted" do
        fund_object = {
            cardId: ENV['TEST_CARD_ID'],
            amount: 20,
            currency: 'USD',
        }
        expect(validator.is_valid_fund_object?(fund_object)).to be true
      end

      it "raises LightrailArgumentError when missing required params" do
        fund_object = {amount: 1, currency: 'USD'}
        expect{validator.is_valid_fund_object?(fund_object)}.to raise_error(lr_argument_error, /fund_object/)
        expect{validator.is_valid_fund_object?({})}.to raise_error(lr_argument_error, /fund_object/)
        expect{validator.is_valid_fund_object?([])}.to raise_error(lr_argument_error, /fund_object/)
      end
    end

  end

  describe "single validator methods" do
    let(:lr_argument_error) {LightrailClientRuby::LightrailArgumentError}

    describe ".is_valid_card_id?" do
      it "returns true for a string of the right format" do
        expect(validator.is_valid_card_id? (ENV['TEST_CARD_ID'])).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.is_valid_card_id? ('')}.to raise_error(lr_argument_error), "called with empty string"
        # expect{validator.is_valid_card_id? ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.is_valid_card_id? (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.is_valid_card_id? ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.is_valid_card_id? ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".is_valid_code?" do
      it "returns true for a string of the right format" do
        expect(validator.is_valid_code? (ENV['TEST_CODE'])).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.is_valid_code? ('')}.to raise_error(lr_argument_error), "called with empty string"
        # expect{validator.is_valid_code? ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.is_valid_code? (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.is_valid_code? ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.is_valid_code? ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".is_valid_transaction_id?" do
      it "returns true for a string of the right format" do
        expect(validator.is_valid_transaction_id? (ENV['TEST_TRANSACTION_ID'])).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.is_valid_transaction_id? ('')}.to raise_error(lr_argument_error), "called with empty string"
        # expect{validator.is_transaction_id_valid? ('some random string')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.is_valid_transaction_id? (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.is_valid_transaction_id? ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.is_valid_transaction_id? ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".is_valid_amount?" do
      it "returns true for an integer" do
        expect(validator.is_valid_amount? (5)).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.is_valid_amount? (5.5)}.to raise_error(lr_argument_error), "called with empty string"
        expect {validator.is_valid_amount? ('five')}.to raise_error(lr_argument_error), "called with number as string"
        expect {validator.is_valid_amount? ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.is_valid_amount? ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

    describe ".is_valid_currency?" do
      it "returns true for an string of the right format" do
        expect(validator.is_valid_currency? ('USD')).to be true
      end

      it "raises LightrailArgumentError for any other type" do
        expect {validator.is_valid_currency? ('XXXX')}.to raise_error(lr_argument_error), "called with invalid string"
        expect {validator.is_valid_currency? (123)}.to raise_error(lr_argument_error), "called with integer"
        expect {validator.is_valid_currency? ({})}.to raise_error(lr_argument_error), "called with empty hash"
        expect {validator.is_valid_currency? ([])}.to raise_error(lr_argument_error), "called with empty array"
      end
    end

  end

end
