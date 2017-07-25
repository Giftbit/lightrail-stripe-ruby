require "spec_helper"

RSpec.describe LightrailClientRuby::Validator do

  describe ".is_valid_card_id?" do
    it "returns true for a string of the right format" do
      expect(LightrailClientRuby::Validator.is_valid_card_id? (ENV['TEST_CARD'])).to be true
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

    it "returns true false for any other type" do
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
