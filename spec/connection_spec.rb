require "spec_helper"

RSpec.describe LightrailClientRuby::Connection do

  describe ".api_base" do
    it "returns the base URL for the Lightrail API" do
      expect(LightrailClientRuby::Connection.api_base).to eq('https://dev.lightrail.com/v1')
    end
  end

  describe ".connection" do
    it "has the right headers" do
      expect(LightrailClientRuby::Connection.connection.headers['Content-Type']).to eq('application/json; charset=utf-8')
      # expect(LightrailClientRuby::Connection.connection.headers['Authorization'].to eq('Bearer'))
    end
  end

end