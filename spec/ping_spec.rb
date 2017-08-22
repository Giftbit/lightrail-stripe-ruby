require "spec_helper"

RSpec.describe Lightrail::Ping do
  subject(:ping) {Lightrail::Ping}

  describe ".ping" do
    it "pings" do
      ping_response = ping.ping
      expect(ping_response).to be_a(ping)
    end
  end

end