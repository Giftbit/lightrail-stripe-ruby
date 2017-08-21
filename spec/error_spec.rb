require "spec_helper"

RSpec.describe Lightrail::LightrailError do
  subject(:error) {Lightrail::LightrailError}

  describe ".initialize" do
    it "should create a new error" do
      response_404 = Faraday::Response.new(status: 404)
      expect(error.new(response_404)).to be_a(Lightrail::LightrailError)
    end
  end

end
