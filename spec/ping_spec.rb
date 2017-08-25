require "spec_helper"

RSpec.describe Lightrail::Ping do
  subject(:ping) {Lightrail::Ping}

  let(:faraday_ping_response) {
    Faraday::Response.new(
        status: 200,
        body: "{\"user\":{\"username\":\"happy_user@example.com\",\"mode\":\"TEST\",\"scopes\":[]}}")
  }

  describe ".ping" do
    it "pings" do
      allow(Lightrail::Connection).to receive_message_chain(:connection, :get).and_return(faraday_ping_response)

      ping_response = ping.ping
      expect(ping_response).to be_a(ping)
    end
  end

end