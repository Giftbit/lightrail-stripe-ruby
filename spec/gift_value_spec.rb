require "spec_helper"

RSpec.describe LightrailClientRuby::GiftValue do

  describe ".retrieve" do
    it "checks balance" do
      balance_response = LightrailClientRuby::GiftValue.retrieve(ENV['TEST_CODE'])
      expect(balance_response).to have_key('balance')
    end
  end

end