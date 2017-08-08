require "spec_helper"

RSpec.describe LightrailClient::Ping do
  subject(:ping) {LightrailClient::Ping}

  describe ".ping" do
    it "pings" do
      ping_response = ping.ping
      expect(ping_response).to be_a(ping)
    end
  end

end