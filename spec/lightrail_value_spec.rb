require "spec_helper"

RSpec.describe LightrailClient::LightrailValue do
  subject(:lightrail_value) {LightrailClient::LightrailValue}

  describe ".retrieve_by_code" do

    context "when given valid params" do
      it "checks balance by code" do
        balance_response = lightrail_value.retrieve_by_code(ENV['LIGHTRAIL_TEST_CODE'])
        expect(balance_response).to be_a(lightrail_value)
        expect(balance_response.principal).to have_key('currentValue')
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_value.retrieve_by_code()}.to raise_error(ArgumentError), "called LightrailValue.retrieve_by_code with no params"
        expect {lightrail_value.retrieve_by_code('')}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve_by_code with empty string"
        expect {lightrail_value.retrieve_by_code({})}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve_by_code with empty object"
        expect {lightrail_value.retrieve_by_code([])}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve_by_code with empty array"
      end
    end

  end

  describe ".retrieve_by_card_id" do

    context "when given valid params" do
      it "checks balance by cardId" do
        balance_response = lightrail_value.retrieve_by_card_id(ENV['LIGHTRAIL_TEST_CARD_ID'])
        expect(balance_response).to be_a(lightrail_value)
        expect(balance_response.principal).to have_key('currentValue')
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_value.retrieve_by_card_id()}.to raise_error(ArgumentError), "called LightrailValue.retrieve_by_card_id with no params"
        expect {lightrail_value.retrieve_by_card_id('')}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve_by_card_id with empty string"
        expect {lightrail_value.retrieve_by_card_id({})}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve_by_card_id with empty object"
        expect {lightrail_value.retrieve_by_card_id([])}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve_by_card_id with empty array"
      end
    end

  end

  describe "#total_available" do

    it "returns the sum of all active value stores" do
      balance_response = lightrail_value.retrieve_by_code(ENV['LIGHTRAIL_TEST_CODE'])
      expect(balance_response.total_available).to be_an(Integer)
    end

    it "excludes value stores if their state is not active" do
      #pending "create a transaction response with an artificial expired/inactive value store"
    end

  end

end