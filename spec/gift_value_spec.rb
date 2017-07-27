require "spec_helper"

RSpec.describe LightrailClientRuby::GiftValue do
  subject(:gift_value) {LightrailClientRuby::GiftValue}

  describe ".retrieve" do

    context "when given valid params" do
      it "checks balance" do
        balance_response = gift_value.retrieve(ENV['TEST_CODE'])
        expect(balance_response).to have_key('balance')
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {gift_value.retrieve()}.to raise_error(ArgumentError), "called GiftValue.retrieve with no params"
        expect {gift_value.retrieve('')}.to raise_error(ArgumentError), "called GiftValue.retrieve with empty string"
        expect {gift_value.retrieve({})}.to raise_error(ArgumentError), "called GiftValue.retrieve with empty object"
        expect {gift_value.retrieve([])}.to raise_error(ArgumentError), "called GiftValue.retrieve with empty array"
      end
    end

  end
end