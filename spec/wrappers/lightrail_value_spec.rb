require "spec_helper"

RSpec.describe Lightrail::LightrailValue do
  subject(:lightrail_value) {Lightrail::LightrailValue}

  let(:lightrail_connection) {Lightrail::Connection}

  let(:example_code) {'this-is-a-code'}
  let(:example_card_id) {'this-is-a-card-id'}
  let(:example_contact_id) {'this-is-a-contact-id'}
  let(:example_shopper_id) {'this-is-a-shopper-id'}
  let(:example_currency) {'ABC'}

  describe ".retrieve_code_details" do
    context "when given valid params" do
      it "gets code details" do
        expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/codes\/#{example_code}\/details/).and_return({"details" => {}})
        lightrail_value.retrieve_code_details(example_code)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_value.retrieve_code_details()}.to raise_error(ArgumentError), "called LightrailValue.retrieve_code_details with no params"
        expect {lightrail_value.retrieve_code_details('')}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_code_details with empty string"
        expect {lightrail_value.retrieve_code_details({})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_code_details with empty object"
        expect {lightrail_value.retrieve_code_details([])}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_code_details with empty array"
      end
    end
  end

  describe ".retrieve_card_details" do
    context "when given valid params" do
      it "gets details by cardId" do
        expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/cards\/#{example_card_id}\/details/).and_return({"details" => {}})
        lightrail_value.retrieve_card_details(example_card_id)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_value.retrieve_card_details()}.to raise_error(ArgumentError), "called LightrailValue.retrieve_card_details with no params"
        expect {lightrail_value.retrieve_card_details('')}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_card_details with empty string"
        expect {lightrail_value.retrieve_card_details({})}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_card_details with empty object"
        expect {lightrail_value.retrieve_card_details([])}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_card_details with empty array"
      end
    end
  end

  describe ".retrieve_contact_account_details" do
    context "when given valid params" do
      it "gets details by contactId" do
        allow(Lightrail::Contact).to receive(:get_account_card_id_by_contact_id).with(example_contact_id, example_currency).and_return(example_card_id)
        expect(lightrail_connection).to receive(:make_get_request_and_parse_response).with(/cards\/#{example_card_id}\/details/).and_return({"details" => {}})
        lightrail_value.retrieve_contact_account_details(example_contact_id, example_currency)
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_value.retrieve_contact_account_details()}.to raise_error(ArgumentError), "called LightrailValue.retrieve_contact_account_details with no params"
        expect {lightrail_value.retrieve_contact_account_details('randomstring')}.to raise_error(ArgumentError), "called LightrailValue.retrieve_contact_account_details with single param"
        expect {lightrail_value.retrieve_contact_account_details('', '')}.to raise_error(Lightrail::LightrailArgumentError), "called LightrailValue.retrieve_contact_account_details with empty strings"
      end
    end
  end

  describe "#maximum_value" do
    before(:each) do
      @details_object = lightrail_value.new({"valueStores" => [{"valueStoreType" => "PRINCIPAL", "value" => 100, "state" => "ACTIVE"},
                                                        {"valueStoreType" => "ATTACHED", "value" => 550, "state" => "ACTIVE"},
                                                        {"valueStoreType" => "ATTACHED", "value" => 1234, "state" => "EXPIRED"}], })
    end

    it "returns the sum of all active value stores" do
      expect(@details_object.maximum_value).to be 650
    end

    it "excludes value stores if their state is not active" do
      @details_object.valueStores[0]['state'] = 'EXPIRED'
      expect(@details_object.maximum_value).to be 550
    end

  end

end