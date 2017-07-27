require "spec_helper"

RSpec.describe LightrailClientRuby::GiftValue do
  describe ".retrieve" do

    context "when given valid params" do
      it "checks balance" do
        balance_response = LightrailClientRuby::GiftValue.retrieve(ENV['TEST_CODE'])
        expect(balance_response).to have_key('balance')
      end
    end

    context "when given bad/missing params" do
      it "throws an error when required params are missing" do
        expect {LightrailClientRuby::GiftValue.retrieve()}.to raise_error(ArgumentError), "called GiftValue.retrieve with no params"
        expect {LightrailClientRuby::GiftValue.retrieve('')}.to raise_error(ArgumentError), "called GiftValue.retrieve with empty string"
        expect {LightrailClientRuby::GiftValue.retrieve({})}.to raise_error(ArgumentError), "called GiftValue.retrieve with empty object"
        expect {LightrailClientRuby::GiftValue.retrieve([])}.to raise_error(ArgumentError), "called GiftValue.retrieve with empty array"
      end
    end

  end
end