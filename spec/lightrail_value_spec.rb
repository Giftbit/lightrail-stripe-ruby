require "spec_helper"

RSpec.describe LightrailClient::LightrailValue do
  subject(:lightrail_value) {LightrailClient::LightrailValue}

  describe ".retrieve" do

    context "when given valid params" do
      it "checks balance" do
        balance_response = lightrail_value.retrieve(ENV['TEST_CODE'])
        expect(balance_response.principal).to have_key('currentValue')
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {lightrail_value.retrieve()}.to raise_error(ArgumentError), "called LightrailValue.retrieve with no params"
        expect {lightrail_value.retrieve('')}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve with empty string"
        expect {lightrail_value.retrieve({})}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve with empty object"
        expect {lightrail_value.retrieve([])}.to raise_error(LightrailClient::LightrailArgumentError), "called LightrailValue.retrieve with empty array"
      end
    end

  end
end