require "spec_helper"

RSpec.describe LightrailClientRuby::Ping do
  subject(:ping) {LightrailClientRuby::Ping}

  describe ".ping" do
    it "pings" do
      ping_response = ping.ping
      expect(ping_response).to be_a(ping)
    end
  end

end