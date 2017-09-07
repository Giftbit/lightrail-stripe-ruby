require "spec_helper"

RSpec.describe Lightrail::LightrailValue do
  subject(:lightrail_value) {Lightrail::LightrailValue}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_code) {'this-is-a-code'}

  let(:example_card_id) {'this-is-a-card-id'}

  describe ".retrieve_by_code" do

    context "when given valid params" do
      it "checks balance by code" do
        expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/codes\/#{example_code}\/balance\/details/).and_return({"balance" => {}})
        lightrail_value.retrieve_by_code(example_code)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_value.retrieve_by_code()}.to raise_error(ArgumentError), "called LightrailValue.retrieve_by_code with no params"
        expect {lightrail_value.retrieve_by_code('')}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_by_code with empty string"
        expect {lightrail_value.retrieve_by_code({})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_by_code with empty object"
        expect {lightrail_value.retrieve_by_code([])}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_by_code with empty array"
      end
    end

  end

  describe ".retrieve_by_card_id" do

    context "when given valid params" do
      it "checks balance by cardId" do
        expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/cards\/#{example_card_id}\/balance/).and_return({"balance" => {}})
        lightrail_value.retrieve_by_card_id(example_card_id)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_value.retrieve_by_card_id()}.to raise_error(ArgumentError), "called LightrailValue.retrieve_by_card_id with no params"
        expect {lightrail_value.retrieve_by_card_id('')}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_by_card_id with empty string"
        expect {lightrail_value.retrieve_by_card_id({})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_by_card_id with empty object"
        expect {lightrail_value.retrieve_by_card_id([])}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_by_card_id with empty array"
      end
    end

  end

  describe "#total_available" do
    before(:each) do
      @balance_object = lightrail_value.new(
          {
              principal: {"currentValue" => 500, "state" => "ACTIVE", "programId" => "program-123456", "valueStoreId" => "value-123456"},
              attached: [
                  {"currentValue" => 100, "state" => "ACTIVE", "programId" => "program-789", "valueStoreId" => "value-2468"},
                  {"currentValue" => 50, "state" => "ACTIVE", "programId" => "program-987", "valueStoreId" => "value-1357"}
              ],
              cardId: 'card-123456',
              currency: 'USD',
              cardType: 'GIFT_CARD',
          }
      )
    end

    it "returns the sum of all active value stores" do
      expect(@balance_object.total_available).to be 650
    end

    it "excludes value stores if their state is not active" do
      @balance_object.attached[0]['state'] = 'EXPIRED'
      expect(@balance_object.total_available).to be 550
    end

  end

end