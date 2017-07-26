require "spec_helper"

RSpec.describe LightrailClientRuby::Validator do
  describe ".is_valid_charge_object?" do
    it "returns true when the required keys are present" do
      charge_object = {
          amount: 1,
          currency: 'USD',
          code: ENV['TEST_CODE'],
      }
      expect(LightrailClientRuby::Validator.is_valid_charge_object?(charge_object)).to be true
    end

    it "returns false when missing required params" do
      charge_object = {
          amount: 1,
          currency: 'USD',
      }
      expect(LightrailClientRuby::Validator.is_valid_charge_object?(charge_object)).to be false
      expect(LightrailClientRuby::Validator.is_valid_charge_object?({})).to be false
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
      expect(LightrailClientRuby::Validator.is_valid_transaction_response?(transaction_response)).to be true
    end

    it "returns false when missing required params" do
      transaction_response = {
          'transaction' => {
              'transactionId' => ENV['TEST_TRANSACTION_ID'],
          }
      }
      expect(LightrailClientRuby::Validator.is_valid_transaction_response?(transaction_response)).to be false
      expect(LightrailClientRuby::Validator.is_valid_transaction_response?({})).to be false
      expect(LightrailClientRuby::Validator.is_valid_transaction_response?([])).to be false
    end
  end

  describe ".is_valid_fund_object?" do
    it "returns true when the required keys are present & formatted" do
      fund_object = {
          cardId: ENV['TEST_CARD_ID'],
          amount: 20,
          currency: 'USD',
      }
      expect(LightrailClientRuby::Validator.is_valid_fund_object?(fund_object)).to be true
    end

    it "returns false when missing required params" do
      expect(LightrailClientRuby::Validator.is_valid_fund_object?({amount: 1, currency: 'USD'})).to be false
      expect(LightrailClientRuby::Validator.is_valid_fund_object?({})).to be false
      expect(LightrailClientRuby::Validator.is_valid_fund_object?([])).to be false
    end
  end

  describe ".is_valid_card_id?" do
    it "returns true for a string of the right format" do
      expect(LightrailClientRuby::Validator.is_valid_card_id? (ENV['TEST_CARD_ID'])).to be true
    end

    it "returns false for any other type" do
      expect(LightrailClientRuby::Validator.is_valid_card_id? ('')).to be false
      # expect(LightrailClientRuby::Validator.is_valid_card_id? ('some random string')).to be false
      expect(LightrailClientRuby::Validator.is_valid_card_id? (123)).to be false
      expect(LightrailClientRuby::Validator.is_valid_card_id? ({})).to be false
      expect(LightrailClientRuby::Validator.is_valid_card_id? ([])).to be false
    end
  end

  describe ".is_valid_code?" do
    it "returns true for a string of the right format" do
      expect(LightrailClientRuby::Validator.is_valid_code? (ENV['TEST_CODE'])).to be true
    end

    it "returns false for any other type" do
      expect(LightrailClientRuby::Validator.is_valid_code? ('')).to be false
      # expect(LightrailClientRuby::Validator.is_valid_code? ('some random string')).to be false
      expect(LightrailClientRuby::Validator.is_valid_code? (123)).to be false
      expect(LightrailClientRuby::Validator.is_valid_code? ({})).to be false
      expect(LightrailClientRuby::Validator.is_valid_code? ([])).to be false
    end
  end

  describe ".is_valid_transaction_id?" do
    it "returns true for a string of the right format" do
      expect(LightrailClientRuby::Validator.is_valid_transaction_id? (ENV['TEST_TRANSACTION_ID'])).to be true
    end

    it "returns false for any other type" do
      expect(LightrailClientRuby::Validator.is_valid_transaction_id? ('')).to be false
      # expect(LightrailClientRuby::Validator.is_transaction_id_valid? ('some random string')).to be false
      expect(LightrailClientRuby::Validator.is_valid_transaction_id? (123)).to be false
      expect(LightrailClientRuby::Validator.is_valid_transaction_id? ({})).to be false
      expect(LightrailClientRuby::Validator.is_valid_transaction_id? ([])).to be false
    end
  end

  describe ".is_valid_amount?" do
    it "returns true for an integer" do
      expect(LightrailClientRuby::Validator.is_valid_amount? (5)).to be true
    end

    it "returns false for any other type" do
      expect(LightrailClientRuby::Validator.is_valid_amount? (5.5)).to be false
      expect(LightrailClientRuby::Validator.is_valid_amount? ('five')).to be false
      expect(LightrailClientRuby::Validator.is_valid_amount? ({})).to be false
      expect(LightrailClientRuby::Validator.is_valid_amount? ([])).to be false
    end
  end

  describe ".is_valid_currency?" do
    it "returns true for an string of the right format" do
      expect(LightrailClientRuby::Validator.is_valid_currency? ('USD')).to be true
    end

    it "returns false for any other type" do
      expect(LightrailClientRuby::Validator.is_valid_currency? ('XXXX')).to be false
      expect(LightrailClientRuby::Validator.is_valid_currency? (123)).to be false
      expect(LightrailClientRuby::Validator.is_valid_currency? ({})).to be false
      expect(LightrailClientRuby::Validator.is_valid_currency? ([])).to be false
    end
  end

end
