require "spec_helper"

RSpec.describe LightrailClientRuby::Ping do

  describe ".ping" do
    it "pings" do
      ping_response = LightrailClientRuby::Ping.ping
      expect(ping_response).to have_key('user')
    end
  end

end