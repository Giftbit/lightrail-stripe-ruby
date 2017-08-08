require "spec_helper"

RSpec.describe LightrailClient::LightrailError do
  subject(:error) {LightrailClient::LightrailError}

  describe ".initialize" do
    it "should create a new error" do
      response_404 = Faraday::Response.new(status: 404)
      expect(error.new(response_404)).to be_a(LightrailClient::LightrailError)
    end
  end

end
